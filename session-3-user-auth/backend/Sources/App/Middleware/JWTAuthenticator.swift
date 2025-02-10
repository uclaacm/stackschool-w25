

import JWT
import Vapor
import Fluent

struct JWTAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
        let payload = try request.jwt.verify(bearer.token, as: AuthPayload.self)
        request.auth.login(payload)
    }

    typealias User = AuthPayload
}
