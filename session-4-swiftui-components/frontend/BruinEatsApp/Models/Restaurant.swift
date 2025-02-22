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

