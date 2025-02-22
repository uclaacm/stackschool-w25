import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UsersController())
    try app.register(collection: RestaurantsController())
    try app.register(collection: ReviewController())
}
