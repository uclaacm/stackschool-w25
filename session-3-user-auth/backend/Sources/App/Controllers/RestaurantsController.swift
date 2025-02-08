//
//  RestaurantsController.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

// RestaurantsController.swift
class RestaurantsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        api.get("restaurants", use: index)
        protected.post("restaurants", use: create)
    }
    
    func index(req: Request) async throws -> [Restaurant] {
        try await Restaurant.query(on: req.db).all()
    }
    

    func create(req: Request) async throws -> Restaurant {
        let userId = try req.auth.require(AuthPayload.self).userId
        let restaurantCreate = try req.content.decode(RestaurantCreate.self)
        
        let restaurant = Restaurant()
        restaurant.name = restaurantCreate.name
        restaurant.description = restaurantCreate.description
        restaurant.imageUrl = restaurantCreate.imageUrl
        restaurant.averageRating = 0  // Set initial rating to 0
        restaurant.$user.id = userId
        
        try Restaurant.validate(content: req)
        try await restaurant.save(on: req.db)
        return restaurant
    }

}
