//
//  RestaurantsController.swift
//  backend
//
//  Created by Shiyu Ye on 2/10/25.
//
import Foundation
import Vapor
import Fluent
import FluentMongoDriver

class RestaurantsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        // GET /api/restaurants
        api.get("restaurants", use: index)
        
        // POST /api/restaurants
        api.post("restaurants", use: create)
    }
    
    func index(req: Request) async throws -> [Restaurant] {
        try await Restaurant.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Restaurant {
        let restaurant = try req.content.decode(Restaurant.self)
        try await restaurant.save(on: req.db)
        return restaurant
    }
}
