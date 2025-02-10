import Foundation

enum Route: Hashable {
    case login
    case register
    case restaurantlistview
}

class AppState: ObservableObject {
    @Published var routes: [Route] = []
    @Published var isAuthenticated = false

    func signOut() {
        routes = [.login]
        isAuthenticated = false
    }

}
