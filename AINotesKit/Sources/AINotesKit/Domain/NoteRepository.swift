import Foundation

/// Abstraction de la persistance des notes. L'implémentation réseau vit dans la couche Data
/// (`RemoteNoteRepository`) ; cette séparation permet de tester la couche Présentation avec
/// un faux repository, sans dépendance réseau.
public protocol NoteRepository: Sendable {
    func fetchAll() async throws -> [Note]
    func fetch(id: UUID) async throws -> Note
    func create(title: String, content: String) async throws -> Note
    func delete(id: UUID) async throws
}
