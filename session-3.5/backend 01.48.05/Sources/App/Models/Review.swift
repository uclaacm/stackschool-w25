//
//  Review.swift
//  backend
//
//  Created by Samuel Perrott on 22/02/25.
//

import Foundation
import Vapor
import Fluent


final class Review: Model, Content, @unchecked Sendable {
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

    init() {}

    init(id: UUID? = nil, userId: UUID, restaurantId: UUID, rating: Int, comment: String) {
        self.id = id
        self.rating = rating
        self.comment = comment
        self.$user.id = userId
        self.$restaurant.id = restaurantId
    }
}

