//
//  ReviewController.swift
//  backend
//
//  Created by Samuel Perrott on 22/02/25.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

class ReviewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        // GET /api/reviews
        api.get("reviews", use: index)
        
        // POST /api/reviews
        protected.post("reviews", use: create)
    }
    
    func index(req: Request) async throws -> [Review] {
        try await Review.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Review {
        let uid = try req.auth.require(AuthPayload.self).uid
        let review = try req.content.decode(Review.self)
        
//         Verify the review is being created for the authenticated user
        guard review.$user.id == uid else {
            throw Abort(.forbidden, reason: "Cannot create review for another user")
        }
        
        try await review.save(on: req.db)
        
        let reviews = try await Review.query(on: req.db)
            .filter(\.$restaurant.$id == review.$restaurant.id)
            .all()
        
        let avgRating = Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
        
        guard let restaurant = try await Restaurant.find(review.$restaurant.id, on: req.db) else {
            throw Abort(.notFound)
        }
        restaurant.averageRating = avgRating
        
        try await restaurant.save(on: req.db)
        
        return review
    }
}
