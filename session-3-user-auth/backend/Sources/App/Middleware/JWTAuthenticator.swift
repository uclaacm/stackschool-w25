//
//  JWTAuthenticator.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

//
//  JWTAuthenticator.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

//import Foundation
//import Vapor
//
//struct JWTAuthenticator: AsyncRequestAuthenticator {
//    func authenticate(request: Request) async throws {
//        try request.jwt.verify(as: AuthPayload.self)
//    }
//}

//
//  JWTAuthenticator.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import JWT
import Vapor
import Fluent

struct JWTAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
        let payload = try request.jwt.verify(bearer.token, as: AuthPayload.self)
        request.auth.login(payload)  // Add this line

    }

    typealias User = AuthPayload
    }
