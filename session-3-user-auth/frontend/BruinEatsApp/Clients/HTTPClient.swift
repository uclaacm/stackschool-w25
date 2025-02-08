import Foundation

enum NetworkError: Error {
    case badRequest
    case serverError(String)
    case decodingError
    case invalidResponse
}

extension NetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            case .badRequest:
                return NSLocalizedString("Unable to perform request", comment: "badRequestError")
            case .serverError(let errorMessage):
                return NSLocalizedString(errorMessage, comment: "serverError")
            case .decodingError:
                return NSLocalizedString("Unable to decode successfully.", comment: "decodingError")
            case .invalidResponse:
                return NSLocalizedString("Invalid response", comment: "invalidResponse")
        }
    }
    
}

enum HTTPMethod {
    case get([URLQueryItem])
    case post(Data?)
    case delete
    
    var name: String {
        switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .delete:
                return "DELETE"
        }
    }
}

struct Resource<T: Codable> {
    let url: URL
    var method: HTTPMethod = .get([])
    var modelType: T.Type
}


struct HTTPClient {
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        
        
        var request = URLRequest(url: resource.url)
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        switch resource.method {
            case .get(let queryItems):
                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
                components?.queryItems = queryItems
                guard let url = components?.url else {
                        throw NetworkError.badRequest
                }
                
                request = URLRequest(url: url)
                
            case .post(let data):
                request.httpMethod = resource.method.name
                request.httpBody = data
            
            case .delete:
                request.httpMethod = resource.method.name
        }
        
        let session = URLSession.shared

        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
            case 401:
                throw NetworkError.serverError("Unauthorized")

            case 409:
                throw NetworkError.serverError("Username is already taken.")
            default:
                break
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let result = try? decoder.decode(resource.modelType, from: data) else {
            throw NetworkError.decodingError
        }
        
        return result
    }
    
}

