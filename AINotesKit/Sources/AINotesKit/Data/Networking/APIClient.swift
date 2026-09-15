import Foundation

/// Abstraction du client réseau, pour permettre de substituer une implémentation factice
/// dans les tests des repositories/services (voir `AINotesKitTests`).
public protocol APIClient: Sendable {
    func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response
    func sendNoContent(_ endpoint: APIEndpoint) async throws
}

/// Implémentation `URLSession` du client API, pointant vers le backend `ai-notes-backend`.
public struct URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        let (data, response) = try await execute(endpoint)
        try validate(response, data: data)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
    }

    public func sendNoContent(_ endpoint: APIEndpoint) async throws {
        let (data, response) = try await execute(endpoint)
        try validate(response, data: data)
    }

    private func execute(_ endpoint: APIEndpoint) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = endpoint.body

        do {
            return try await session.data(for: request)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error.localizedDescription)
        }
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }
    }
}
