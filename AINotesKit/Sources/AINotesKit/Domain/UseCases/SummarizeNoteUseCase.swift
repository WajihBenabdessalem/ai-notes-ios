import Foundation

/// Résume une note existante via le service IA. Utilise `callAsFunction` pour un site d'appel
/// idiomatique : `try await summarizeNote(noteID: id)`.
public struct SummarizeNoteUseCase: Sendable {
    private let aiService: AIService

    public init(aiService: AIService) {
        self.aiService = aiService
    }

    public func callAsFunction(noteID: UUID) async throws -> String {
        try await aiService.summarize(noteID: noteID)
    }
}
