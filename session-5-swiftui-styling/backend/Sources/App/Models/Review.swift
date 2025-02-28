//
//  Review.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//


import Foundation
import Vapor
import Fluent

final class Review: Model, Content, Validatable {
    
    static let schema = "reviews"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "rating")
    var rating: Int
    
    @Field(key: "comment")
    var comment: String
    
    @Parent(key: "userId")
    var user: User
    
    @Parent(key: "restaurantId")
    var restaurant: Restaurant
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    
    init() { }
    
    init(id: UUID? = nil, rating: Int, comment: String, userId: UUID, restaurantId: UUID) {
        self.id = id
        self.rating = rating
        self.comment = comment
        self.$user.id = userId
        self.$restaurant.id = restaurantId
    }

    static func validations(_ validations: inout Validations) {
    }

}
