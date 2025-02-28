import Foundation
import SwiftUI

//class BruinEatsModel: ObservableObject {
//    @Published var restaurants: [Restaurant] = []
//    @Published var reviewsByRestaurant: [UUID: [Review]] = [:]
//    @Published private var appState = AppState()
//    
//    private let controller = RestaurantController.shared
//    
//    // MARK: - User Authentication
//    func register(username: String, password: String) async throws {
//        try await controller.register(username: username, password: password)
//    }
//    
//    func login(username: String, password: String) async throws -> [String: String] {
//        do {
//            let (token, userId) = try await controller.login(username: username, password: password)
//            
//            // Save the token and userId in UserDefaults
//            let defaults = UserDefaults.standard
//            defaults.set(token, forKey: "authToken")
//            defaults.set(userId, forKey: "userId")
//            
//            await MainActor.run {
//                appState.isAuthenticated = true
//            }
//            
//            try? await fetchRestaurants()
//            
//            // Return success response without error
//            return ["error": "false"]
//            
//        } catch {
//            // Return error response
//            return [
//                "error": "true",
//                "reason": error.localizedDescription
//            ]
//        }
//    }
//
//    func signOut() {
//        UserDefaults.standard.removeObject(forKey: "authToken")
//        UserDefaults.standard.removeObject(forKey: "userId")
//        
//        // Clear local data
//        Task { @MainActor in
//            self.restaurants = []
//            self.reviewsByRestaurant = [:]
//            self.appState.isAuthenticated = false
//        }
//    }
//    
//    // MARK: - Restaurant Management
//    func fetchRestaurants() async throws {
//        let fetchedRestaurants = try await controller.fetchRestaurants()
//        
//        await MainActor.run {
//            self.restaurants = fetchedRestaurants
//        }
//    }
//    
//    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
//        let restaurant = try await controller.addRestaurant(name: name, description: description, imageUrl: imageUrl)
//        
//        await MainActor.run {
//            self.restaurants.append(restaurant)
//        }
//        return restaurant
//    }
//    
//    // MARK: - Reviews Management
//    func fetchReviews(for restaurantId: UUID) async throws {
//        let fetchedReviews = try await controller.fetchReviews(for: restaurantId)
//        
//        await MainActor.run {
//            self.reviewsByRestaurant[restaurantId] = fetchedReviews
//        }
//    }
//    
//    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
//        let review = try await controller.addReview(restaurantId: restaurantId, rating: rating, comment: comment)
//        
//        await MainActor.run {
//            if self.reviewsByRestaurant[restaurantId] != nil {
//                self.reviewsByRestaurant[restaurantId]?.append(review)
//                self.reviewsByRestaurant[restaurantId]?.sort { $0.createdAt > $1.createdAt }
//            } else {
//                self.reviewsByRestaurant[restaurantId] = [review]
//            }
//        }
//        return review
//    }
//}

class BruinEatsModel: ObservableObject {
    static let shared = BruinEatsModel()
    
    @Published var restaurants: [Restaurant] = []
    @Published var reviewsByRestaurant: [UUID: [Review]] = [:]
    @Published private var appState = AppState()
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private func makeRequest(_ method: HTTPMethod, url: URL, body: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
    
    // MARK: - Auth Methods
    func register(username: String, password: String) async throws {
        let body = ["username": username, "password": password]
        _ = try await URLSession.shared.data(for: makeRequest(.post, url: Constants.Urls.register, body: body))
    }
    
    func login(username: String, password: String) async throws -> [String: String] {
        do {
            let body = ["username": username, "password": password]
            let (data, _) = try await URLSession.shared.data(for: makeRequest(.post, url: Constants.Urls.login, body: body))
            let response = try decoder.decode([String: String].self, from: data)
            
            guard let token = response["token"],
                  let userId = response["userId"] else {
                throw NetworkError.decodingError
            }
            
            // Save auth data
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "authToken")
            defaults.set(userId, forKey: "userId")
            
            await MainActor.run {
                appState.isAuthenticated = true
            }
            
            try? await fetchRestaurants()
            return ["error": "false"]
            
        } catch {
            return [
                "error": "true",
                "reason": error.localizedDescription
            ]
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        Task { @MainActor in
            self.restaurants = []
            self.reviewsByRestaurant = [:]
            self.appState.isAuthenticated = false
        }
    }
    
    // MARK: - Restaurant Methods
    func fetchRestaurants() async throws {
        let request = makeRequest(.get, url: Constants.Urls.restaurants)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedRestaurants = try decoder.decode([Restaurant].self, from: data)
        
        await MainActor.run {
            self.restaurants = fetchedRestaurants
        }
    }
    
    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
        let body = ["name": name, "description": description, "imageUrl": imageUrl].compactMapValues { $0 }
        let request = makeRequest(.post, url: Constants.Urls.restaurants, body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let restaurant = try decoder.decode(Restaurant.self, from: data)
        
        await MainActor.run {
            self.restaurants.append(restaurant)
        }
        return restaurant
    }
    
    // MARK: - Review Methods
    func fetchReviews(for restaurantId: UUID) async throws {
        var components = URLComponents(url: Constants.Urls.reviews, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "restaurantId", value: restaurantId.uuidString)]
        
        let request = makeRequest(.get, url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let fetchedReviews = try decoder.decode([Review].self, from: data)
        
        await MainActor.run {
            self.reviewsByRestaurant[restaurantId] = fetchedReviews
        }
    }
    
    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
        let body = [
            "restaurantId": restaurantId.uuidString,
            "rating": rating,
            "comment": comment
        ] as [String: Any]
        
        let request = makeRequest(.post, url: Constants.Urls.reviews, body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let review = try decoder.decode(Review.self, from: data)
        
        await MainActor.run {
            if self.reviewsByRestaurant[restaurantId] != nil {
                self.reviewsByRestaurant[restaurantId]?.append(review)
                self.reviewsByRestaurant[restaurantId]?.sort { $0.createdAt > $1.createdAt }
            } else {
                self.reviewsByRestaurant[restaurantId] = [review]
            }
        }
        return review
    }
}

enum NetworkError: LocalizedError {
   case badRequest
   case serverError(String)
   case decodingError
   case invalidResponse

   var errorDescription: String? {
       switch self {
       case .badRequest: return "Unable to perform request"
       case .serverError(let message): return message
       case .decodingError: return "Unable to decode response"
       case .invalidResponse: return "Invalid response from server"
       }
   }
}
