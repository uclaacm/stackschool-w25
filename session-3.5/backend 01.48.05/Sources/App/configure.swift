import Vapor
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(
        .mongo(connectionString: "yourdb_string"),
        as: .mongo
    )
    
    app.jwt.signers.use(.hs256(key: "SECRETKEY"))
    
    // register routes
    try routes(app)
}
