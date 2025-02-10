import Foundation
import JWT
import Fluent
import Vapor

struct AuthPayload: JWTPayload, Authenticatable {
    // Required coding keys for JWT
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case userId = "uid"
    }
    
    var expiration: ExpirationClaim
    var userId: UUID
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

struct JWTAuthenticator: AsyncBearerAuthenticator {
    typealias User = AuthPayload  // Required by AsyncBearerAuthenticator
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try request.jwt.verify(bearer.token, as: AuthPayload.self)
        request.auth.login(payload)
    }
}
