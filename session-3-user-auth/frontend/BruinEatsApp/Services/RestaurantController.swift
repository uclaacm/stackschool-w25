import Foundation

class RestaurantController {
    static let shared = RestaurantController()
    
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
    
    // MARK: - Auth
    func register(username: String, password: String) async throws {
        let body = ["username": username, "password": password]
        _ = try await URLSession.shared.data(for: makeRequest(.post, url: Constants.Urls.register, body: body))
    }
    
    func login(username: String, password: String) async throws -> (token: String, userId: String) {
        let body = ["username": username, "password": password]
        let (data, _) = try await URLSession.shared.data(for: makeRequest(.post, url: Constants.Urls.login, body: body))
        let response = try decoder.decode([String: String].self, from: data)
        
        guard let token = response["token"],
              let userId = response["userId"] else {
            throw NetworkError.decodingError
        }
        
        return (token, userId)
    }
    
    // MARK: - Restaurants
    // MARK: - Restaurants
    
    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {

        let body = [
            "restaurantId": restaurantId.uuidString,
            "rating": rating,
            "comment": comment
        ] as [String: Any]
        
        let request = makeRequest(.post, url: Constants.Urls.reviews, body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try decoder.decode(Review.self, from: data)
    }


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

    // MARK: - Restaurant Methods
    func fetchRestaurants() async throws -> [Restaurant] {
        let request = makeRequest(.get, url: Constants.Urls.restaurants)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode([Restaurant].self, from: data)
    }

    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
        let body = ["name": name, "description": description, "imageUrl": imageUrl].compactMapValues { $0 }
        let request = makeRequest(.post, url: Constants.Urls.restaurants, body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(Restaurant.self, from: data)
    }

    // MARK: - Reviews
    func fetchReviews(for restaurantId: UUID) async throws -> [Review] {
        var components = URLComponents(url: Constants.Urls.reviews, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "restaurantId", value: restaurantId.uuidString)]
        
        let request = makeRequest(.get, url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode([Review].self, from: data)
    }}

// MARK: - Errors
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
