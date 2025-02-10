import Foundation
import SwiftUI

class BruinEatsModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var reviewsByRestaurant: [UUID: [Review]] = [:]
    @Published private var appState = AppState()
    
    private let controller = RestaurantController.shared
    
    // MARK: - User Authentication
    func register(username: String, password: String) async throws {
        try await controller.register(username: username, password: password)
    }
    
    func login(username: String, password: String) async throws -> [String: String] {
        do {
            let (token, userId) = try await controller.login(username: username, password: password)
            
            // Save the token and userId in UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "authToken")
            defaults.set(userId, forKey: "userId")
            
            await MainActor.run {
                appState.isAuthenticated = true
            }
            
            try? await fetchRestaurants()
            
            // Return success response without error
            return ["error": "false"]
            
        } catch {
            // Return error response
            return [
                "error": "true",
                "reason": error.localizedDescription
            ]
        }
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        // Clear local data
        Task { @MainActor in
            self.restaurants = []
            self.reviewsByRestaurant = [:]
            self.appState.isAuthenticated = false
        }
    }
    
    // MARK: - Restaurant Management
    func fetchRestaurants() async throws {
        let fetchedRestaurants = try await controller.fetchRestaurants()
        
        await MainActor.run {
            self.restaurants = fetchedRestaurants
        }
    }
    
    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
        let restaurant = try await controller.addRestaurant(name: name, description: description, imageUrl: imageUrl)
        
        await MainActor.run {
            self.restaurants.append(restaurant)
        }
        return restaurant
    }
    
    // MARK: - Reviews Management
    func fetchReviews(for restaurantId: UUID) async throws {
        let fetchedReviews = try await controller.fetchReviews(for: restaurantId)
        
        await MainActor.run {
            self.reviewsByRestaurant[restaurantId] = fetchedReviews
        }
    }
    
    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
        let review = try await controller.addReview(restaurantId: restaurantId, rating: rating, comment: comment)
        
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
