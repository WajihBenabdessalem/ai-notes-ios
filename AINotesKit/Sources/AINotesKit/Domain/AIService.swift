import Foundation

/// Résultat d'une recherche sémantique : une note et son score de pertinence (0...1).
public struct SearchResult: Sendable, Equatable {
    public let note: Note
    public let score: Double

    public init(note: Note, score: Double) {
        self.note = note
        self.score = score
    }
}

/// Résultat d'un échange avec l'assistant : la réponse et les notes utilisées comme source.
public struct ChatResult: Sendable, Equatable {
    public let answer: String
    public let sourceNoteIDs: [UUID]

    public init(answer: String, sourceNoteIDs: [UUID]) {
        self.answer = answer
        self.sourceNoteIDs = sourceNoteIDs
    }
}

/// Abstraction des fonctionnalités IA exposées par le backend (résumé, recherche, chat).
public protocol AIService: Sendable {
    func summarize(noteID: UUID) async throws -> String
    func search(query: String) async throws -> [SearchResult]
    func chat(message: String) async throws -> ChatResult
}
