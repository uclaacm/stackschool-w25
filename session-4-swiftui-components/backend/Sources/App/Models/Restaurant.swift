//
//  Restaurant.swift
//  backend
//
//  Created by Shiyu Ye on 1/31/25.
//

import Foundation
import Vapor
import Fluent

final class Restaurant: Model, Content, @unchecked Sendable {
   static let schema = "restaurants"
   
   @ID(key: .id)
   var id: UUID?
   
   @Field(key: "name")
   var name: String
   
   @Field(key: "imageUrl")
   var imageUrl: String?
   
   @Field(key: "averageRating")
   var averageRating: Double
   
   init() {}
   
   init(id: UUID? = nil, name: String, description: String, imageUrl: String? = nil, averageRating: Double = 0.0, userId: UUID) {
       self.id = id
       self.name = name
       self.imageUrl = imageUrl
       self.averageRating = averageRating
   }
}
