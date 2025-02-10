//
//  ReviewDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 08/02/25.
//

import Vapor

struct ReviewDTO: Content {
    let comment: String
    let rating: Int
    let restaurantId: UUID
}
