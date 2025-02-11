//
//  JWTAuthenticator.swift
//  backend
//
//  Created by Shiyu Ye on 2/10/25.
//

import JWT
import Fluent
import Vapor
import Foundation

struct AuthPayload: JWTPayload, Authenticatable {
    var exp: ExpirationClaim
    var uid: UUID
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}


