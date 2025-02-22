//
//  Review.swift
//  BruinEatsApp
//
//  Created by Samuel Perrott on 10/02/25.
//

import Foundation

struct Review: Codable, Identifiable {
    let id: UUID
    let rating: Int
    let comment: String
    let createdAt: Date
    let user: User
    let restaurant: RestaurantReference
    
    struct User: Codable {
        let id: UUID
        let username: String
        private enum CodingKeys: String, CodingKey {
            case id
            case username
            // Explicitly not including password
        }

    }
    struct RestaurantReference: Codable {
        let id: UUID
    }

}
