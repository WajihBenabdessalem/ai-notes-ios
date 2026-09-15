import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

/// Description d'un appel HTTP, indépendante de l'implémentation du client (facilite les tests).
public struct APIEndpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let body: Data?

    public init(path: String, method: HTTPMethod, body: Data? = nil) {
        self.path = path
        self.method = method
        self.body = body
    }

    public static func encode(_ value: some Encodable) -> Data? {
        try? JSONEncoder().encode(value)
    }
}
