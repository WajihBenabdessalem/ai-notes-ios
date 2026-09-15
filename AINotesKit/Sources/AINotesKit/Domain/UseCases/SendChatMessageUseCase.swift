import Foundation

/// Envoie un message à l'assistant IA, qui répond en s'appuyant sur les notes pertinentes.
public struct SendChatMessageUseCase: Sendable {
    private let aiService: AIService

    public init(aiService: AIService) {
        self.aiService = aiService
    }

    public func callAsFunction(message: String) async throws -> ChatResult {
        try await aiService.chat(message: message)
    }
}
