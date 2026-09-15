import Foundation

/// Point de composition unique de l'app : assemble les implémentations concrètes derrière
/// les protocoles du domaine. L'app cible (AINotesApp) n'instancie que ce type.
public final class AppContainer: Sendable {
    public let noteRepository: NoteRepository
    public let aiService: AIService

    public init(baseURL: URL) {
        let client = URLSessionAPIClient(baseURL: baseURL)
        self.noteRepository = RemoteNoteRepository(client: client)
        self.aiService = RemoteAIService(client: client)
    }

    /// Initialiseur secondaire pratique pour les previews SwiftUI ou les tests d'intégration
    /// côté app, avec des implémentations factices.
    public init(noteRepository: NoteRepository, aiService: AIService) {
        self.noteRepository = noteRepository
        self.aiService = aiService
    }
}
