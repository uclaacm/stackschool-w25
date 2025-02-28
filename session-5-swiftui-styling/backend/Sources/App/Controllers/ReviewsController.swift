//
//  ReviewsController.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//
import Foundation
import Vapor
import Fluent
import FluentMongoDriver

// ReviewsController.swift
class ReviewsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        api.get("reviews", use: index)
        protected.post("reviews", use: create)
    }
    
    func index(req: Request) async throws -> [Review] {
        guard let restaurantId = req.query[UUID.self, at: "restaurantId"] else {
            throw Abort(.badRequest)
        }
        
        return try await Review.query(on: req.db)
            .filter(\.$restaurant.$id == restaurantId)
            .with(\.$user)
            .all()
    }
    
    func create(req: Request) async throws -> Review {
        let userId = try req.auth.require(AuthPayload.self).userId
        let reviewCreate = try req.content.decode(ReviewCreate.self)
        
        // Create a new review from the DTO
        let review = Review()
        review.comment = reviewCreate.comment
        review.rating = reviewCreate.rating
        review.$restaurant.id = reviewCreate.restaurantId
        review.$user.id = userId
        
        // Validate the review
        try Review.validate(content: req)
        
        try await review.save(on: req.db)
        
        // Rest of your code for updating restaurant rating...
        let reviews = try await Review.query(on: req.db)
            .filter(\.$restaurant.$id == review.$restaurant.id)
            .all()
        
        let avgRating = Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
        
        guard let restaurant = try await Restaurant.find(review.$restaurant.id, on: req.db) else {
            throw Abort(.notFound)
        }
        restaurant.averageRating = avgRating
        try await restaurant.save(on: req.db)
        
        return try await Review.query(on: req.db)
            .filter(\.$id == review.id!)
            .with(\.$user)
            .first() ?? review
    }
}
