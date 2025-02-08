
import Foundation
import SwiftUI

class BruinEatsModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var reviewsByRestaurant: [UUID: [Review]] = [:]
    @Published private var appState = AppState()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let httpClient = HTTPClient()

    // MARK: - User Authentication

    // Then update the register function to use this type
    func register(username: String, password: String) async throws  {
        let userData = [
            "username": username,
            "password": password
        ]
        
        let resource = try Resource(
            url: Constants.Urls.register,
            method: .post(JSONEncoder().encode(userData)),
            modelType: [String: String].self
        )
        let _ = try await httpClient.load(resource)

    }

    func login(username: String, password: String) async throws -> [String: String] {
        let loginData = ["username": username, "password": password]
        let resource = try Resource(
            url: Constants.Urls.login,
            method: .post(JSONEncoder().encode(loginData)),
            modelType: [String: String].self
        )

        let response = try await httpClient.load(resource)
        
        if let token = response["token"],
           let userId = response["userId"] {
            // Save the token and userId in UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "authToken")
            defaults.set(userId, forKey: "userId")
            
            await MainActor.run {
                appState.isAuthenticated = true
            }

            try? await fetchRestaurants()
        }

        return response
    }

    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
        let restaurantData = [
            "name": name,
            "description": description,
            "imageUrl": imageUrl
        ].compactMapValues { $0 }
        
        let resource = try Resource(
            url: Constants.Urls.restaurants,
            method: .post(JSONEncoder().encode(restaurantData)),
            modelType: Restaurant.self
        )
        let restaurant = try await httpClient.load(resource)
        
        await MainActor.run {
            self.restaurants.append(restaurant)
        }
        return restaurant
    }

    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
        let reviewRequest = ReviewRequest(
            restaurantId: restaurantId.uuidString,
            rating: rating,
            comment: comment
        )
        
        let resource = try Resource(
            url: Constants.Urls.reviews,
            method: .post(JSONEncoder().encode(reviewRequest)),
            modelType: Review.self
        )
        
        let review = try await httpClient.load(resource)
        
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

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        // Clear local data
        DispatchQueue.main.async {
            self.restaurants = []
            self.reviewsByRestaurant = [:]
        }
    }

    // MARK: - Restaurant Management


    func fetchRestaurants() async throws {
        let resource = Resource(
            url: Constants.Urls.restaurants,
            method: .get([]),
            modelType: [Restaurant].self
        )
        let fetchedRestaurants = try await httpClient.load(resource)
        
        await MainActor.run {
            self.restaurants = fetchedRestaurants
        }
    }

    // MARK: - Reviews Management

    func fetchReviews(for restaurantId: UUID) async throws {
        let queryItems = [URLQueryItem(name: "restaurantId", value: restaurantId.uuidString)]
        let resource = Resource(
            url: Constants.Urls.reviews,
            method: .get(queryItems),
            modelType: [Review].self
        )
        let fetchedReviews = try await httpClient.load(resource)

        await MainActor.run {
            self.reviewsByRestaurant[restaurantId] = fetchedReviews
        }
    }
}
