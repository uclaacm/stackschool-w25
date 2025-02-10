//
//  RestaurantsRoutes.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 10/02/25.
//


import Foundation
import Vapor
import Fluent
import FluentMongoDriver

// RestaurantsController.swift

struct RestaurantsRoutes: RouteCollection {
    let controller = RestaurantsController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        api.get("restaurants") { req in
            try await controller.index(req: req)
        }
        protected.post("restaurants") { req in
            try await controller.create(req: req)
        }
    }
}
