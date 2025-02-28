import Foundation
import JWT
import Fluent
import Vapor

struct AuthPayload: JWTPayload, Authenticatable {
    typealias Payload = AuthPayload
    
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
