import Foundation
import Vapor
import Fluent
import FluentMongoDriver

actor UsersController {
    func login(req: Request) async throws -> Response {
        // decode the request
        let credentials = try req.content.decode(User.self)
        
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == credentials.username)
            .first() else {
            return Response(status: .unauthorized,
                          body: .init(string: "Username is not found."))
        }
        
        // validate the password
        let result = try await req.password.async.verify(
            credentials.password,
            created: existingUser.password
        )
        
        if !result {
            return Response(status: .unauthorized,
                          body: .init(string: "Password is incorrect."))
        }
        
        // generate the token
        let authPayload = try AuthPayload(
            expiration: .init(value: Date.distantFuture),
            userId: existingUser.requireID()
        )
        
        // return token and user ID
        let userId = try existingUser.requireID()
        let response = [
            "token": try req.jwt.sign(authPayload),
            "userId": userId.uuidString
        ]
        
        return try Response(
            status: .ok,
            headers: ["Content-Type": "application/json"],
            body: .init(data: JSONEncoder().encode(response))
        )
    }
    
    func register(req: Request) async throws -> Response {
        // validate the user
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
        
        // check if username is taken
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            return Response(
                status: .conflict,
                body: .init(string: "Username is already taken.")
            )
        }
        
        // hash the password
        user.password = try await req.password.async.hash(user.password)
        
        // save the user
        try await user.save(on: req.db)
        
        
        
        return Response(
            status: .created,
            headers: ["Content-Type": "application/json"],
            body: .init(data: try JSONEncoder().encode(["message": "Registration successful"]))
        )
    }
}
