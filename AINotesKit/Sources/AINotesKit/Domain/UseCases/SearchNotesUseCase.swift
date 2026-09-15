import Foundation

/// Recherche sémantique parmi les notes de l'utilisateur.
public struct SearchNotesUseCase: Sendable {
    private let aiService: AIService

    public init(aiService: AIService) {
        self.aiService = aiService
    }

    public func callAsFunction(query: String) async throws -> [SearchResult] {
        try await aiService.search(query: query)
    }
}
