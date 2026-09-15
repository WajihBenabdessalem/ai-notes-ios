import Foundation

// Les DTOs restent `internal` (non `public`) : ce sont des détails d'implémentation de la
// couche Data, jamais exposés au domaine ni à la présentation. Les tests y accèdent via
// `@testable import AINotesKit`.

struct NoteDTO: Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case createdAt = "created_at"
    }

    func toDomain() -> Note {
        Note(id: id, title: title, content: content, createdAt: createdAt)
    }
}

struct CreateNoteRequestDTO: Encodable {
    let title: String
    let content: String
}

struct SummarizeResponseDTO: Decodable {
    let summary: String
}

struct SearchRequestDTO: Encodable {
    let query: String
}

struct SearchResultDTO: Decodable {
    let note: NoteDTO
    let score: Double
}

struct ChatRequestDTO: Encodable {
    let message: String
}

struct ChatResponseDTO: Decodable {
    let answer: String
    let sourceNoteIds: [UUID]

    enum CodingKeys: String, CodingKey {
        case answer
        case sourceNoteIds = "source_note_ids"
    }
}
