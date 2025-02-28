import Foundation

struct Constants {
    
    private static let baseUrlPath = "http://127.0.0.1:8080/api"
    
    struct Urls {
        
        static let register = URL(string: "\(baseUrlPath)/register")!
        static let login = URL(string: "\(baseUrlPath)/login")!
        static let restaurants = URL(string: "\(baseUrlPath)/restaurants")!
        static let reviews = URL(string: "\(baseUrlPath)/reviews")!

    }
}
