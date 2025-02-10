//
//  ReviewsRoutes.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 10/02/25.
//


import Foundation
import Vapor
import Fluent
import FluentMongoDriver

struct ReviewsRoutes: RouteCollection {
    let controller = ReviewsController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        api.get("reviews") { req in
            try await controller.index(req: req)
        }
        protected.post("reviews") { req in
            try await controller.create(req: req)
        }
    }
}
