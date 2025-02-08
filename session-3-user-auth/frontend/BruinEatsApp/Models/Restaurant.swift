//
//  Restaurant.swift
//  BruinEatsApp
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation

struct Restaurant: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let imageUrl: String?
    let createdAt: Date
    let averageRating: Double
    let user: User
    
    struct User: Codable {
        let id: UUID
    }
}

struct Review: Codable, Identifiable {
    let id: UUID
    let rating: Int
    let comment: String
    let createdAt: Date
    let user: User
    let restaurant: Restaurant
    
    struct User: Codable {
        let id: UUID
        let username: String
    }
}

// First create a struct to handle registration responses


struct ReviewRequest: Encodable {
    let restaurantId: String
    let rating: Int
    let comment: String
}

