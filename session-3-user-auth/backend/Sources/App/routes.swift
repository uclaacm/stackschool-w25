import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    // register controllers

    try app.register(collection: UsersRoutes())
    try app.register(collection: RestaurantsRoutes())
    try app.register(collection: ReviewsRoutes())

}
