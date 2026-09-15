import Foundation

/// Implémentation réseau de `NoteRepository`, qui traduit les DTOs du backend en modèles domaine.
public struct RemoteNoteRepository: NoteRepository {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func fetchAll() async throws -> [Note] {
        let dtos: [NoteDTO] = try await client.send(APIEndpoint(path: "/notes", method: .get))
        return dtos.map { $0.toDomain() }
    }

    public func fetch(id: UUID) async throws -> Note {
        let dto: NoteDTO = try await client.send(
            APIEndpoint(path: "/notes/\(id.uuidString)", method: .get)
        )
        return dto.toDomain()
    }

    public func create(title: String, content: String) async throws -> Note {
        let body = APIEndpoint.encode(CreateNoteRequestDTO(title: title, content: content))
        let dto: NoteDTO = try await client.send(
            APIEndpoint(path: "/notes", method: .post, body: body)
        )
        return dto.toDomain()
    }

    public func delete(id: UUID) async throws {
        try await client.sendNoContent(APIEndpoint(path: "/notes/\(id.uuidString)", method: .delete))
    }
}
