import Foundation
import JWT
import Fluent
import Vapor


struct AuthPayload: JWTPayload, Authenticatable {
    var exp: ExpirationClaim
    var uid: UUID
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

struct JWTAuthenticator: AsyncBearerAuthenticator {
    typealias User = AuthPayload
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try request.jwt.verify(bearer.token, as: AuthPayload.self)
        request.auth.login(payload)
    }
}
