//
//  UsersRoutes.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 10/02/25.
//


import Foundation
import Vapor
import Fluent
import FluentMongoDriver

struct UsersRoutes: RouteCollection {
    let controller = UsersController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        api.post("register") { req in
            try await controller.register(req: req)
        }
        api.post("login") { req in
            try await controller.login(req: req)
        }
    }
}
