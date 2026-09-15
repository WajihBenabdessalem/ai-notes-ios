import Foundation

public enum APIError: Error, Equatable, Sendable {
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case decoding(String)
    case transport(String)
}
