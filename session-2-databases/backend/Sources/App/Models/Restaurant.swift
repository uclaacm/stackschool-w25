//
//  Restaurant.swift
//  backend
//
//  Created by Shiyu Ye on 1/31/25.
//

import Foundation
import Vapor
import Fluent

final class Restaurant: Model, Content, Validatable {
   static let schema = "restaurants"
   
   @ID(key: .id)
   var id: UUID?
   
   @Field(key: "name")
   var name: String
   
   @Field(key: "description")
   var description: String
   
   @Field(key: "imageUrl")
   var imageUrl: String?
   
   @Field(key: "averageRating")
   var averageRating: Double
   
   @Parent(key: "userId")
   var user: User
   
   @Timestamp(key: "createdAt", on: .create)
   var createdAt: Date?
   
   init() {}
   
   init(id: UUID? = nil, name: String, description: String, imageUrl: String? = nil, averageRating: Double = 0.0, userId: UUID) {
       self.id = id
       self.name = name
       self.description = description
       self.imageUrl = imageUrl
       self.averageRating = averageRating
       self.$user.id = userId
   }
    
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty, customFailureDescription: "Name cannot be empty.")
    }
}
