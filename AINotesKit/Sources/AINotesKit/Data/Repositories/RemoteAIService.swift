import Foundation

/// Implémentation réseau de `AIService`, consommant les endpoints IA du backend.
public struct RemoteAIService: AIService {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func summarize(noteID: UUID) async throws -> String {
        let response: SummarizeResponseDTO = try await client.send(
            APIEndpoint(path: "/notes/\(noteID.uuidString)/summarize", method: .post)
        )
        return response.summary
    }

    public func search(query: String) async throws -> [SearchResult] {
        let body = APIEndpoint.encode(SearchRequestDTO(query: query))
        let results: [SearchResultDTO] = try await client.send(
            APIEndpoint(path: "/search", method: .post, body: body)
        )
        return results.map { SearchResult(note: $0.note.toDomain(), score: $0.score) }
    }

    public func chat(message: String) async throws -> ChatResult {
        let body = APIEndpoint.encode(ChatRequestDTO(message: message))
        let response: ChatResponseDTO = try await client.send(
            APIEndpoint(path: "/chat", method: .post, body: body)
        )
        return ChatResult(answer: response.answer, sourceNoteIDs: response.sourceNoteIds)
    }
}
