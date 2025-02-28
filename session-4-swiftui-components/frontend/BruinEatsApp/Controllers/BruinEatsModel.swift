//
//  BruinEatsModel.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 2/24/25.
//

import Foundation
import SwiftUI

class BruinEatsModel: ObservableObject {
    static let shared = BruinEatsModel()
    
    @Published var restaurants: [Restaurant] = []
    
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
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }
    
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
}


