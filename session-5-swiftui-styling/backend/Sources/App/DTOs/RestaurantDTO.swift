//
//  RestaurantDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 08/02/25.
//
import Vapor

struct RestaurantCreate: Content {
    let name: String
    let description: String
    let imageUrl: String?
    // Note: no averageRating field
}
