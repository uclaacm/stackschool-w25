//
//  UsersController.swift
//  backend
//
//  Created by Shiyu Ye on 2/10/25.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

class UsersController : RouteCollection {
    
    // api/register
    
    // api/login
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        // POST /api/register
        api.post("register", use: register)
        
        // POST /api/login
        api.post("login", use: login)
    }
    
    func register(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        // check if this username is already taken
        try await user.save(on: req.db)
        return user
    }
    
    func login(req: Request) async throws -> Response {
        let user = try req.content.decode(User.self)
        
        guard let existingUser = try await User.query(on: req.db).filter(\.$username == user.username).first() else {
            return Response(status: .unauthorized, body: .init(string: "username does not exist"))
        }
        
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        
        if !result {
            return Response(status: .unauthorized, body: .init(string: "password incorrect"))
        }
        
        let authPayload = try AuthPayload(
            exp: .init(value: Date.distantFuture),
            uid: existingUser.requireID()
        )
        
        
        let userId = try existingUser.requireID()

        let response = [
            "token" : try req.jwt.sign(authPayload),
            "userId" : userId.uuidString
        ]
        
        return try Response(
            status: .ok,
            headers: ["Content-Type": "application/json"],
            body: .init(data: JSONEncoder().encode(response))
        )
    }
}
