import SwiftUI
import AINotesKit

@main
struct AINotesApp: App {
    private let container: AppContainer

    init() {
        // En développement : simulateur -> http://localhost:8000
        //                    appareil physique -> IP locale de votre Mac, ex: http://192.168.1.23:8000
        // Voir ../backend/README.md pour lancer le serveur.
        let baseURL = URL(string: "http://localhost:8000")!
        container = AppContainer(baseURL: baseURL)
    }

    var body: some Scene {
        WindowGroup {
            NotesListView(container: container)
        }
    }
}
