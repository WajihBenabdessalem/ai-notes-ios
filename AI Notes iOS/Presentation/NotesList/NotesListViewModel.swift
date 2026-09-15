import Foundation
import Observation
import AINotesKit

@MainActor
@Observable
final class NotesListViewModel {
    private(set) var notes: [Note] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let repository: NoteRepository

    init(repository: NoteRepository) {
        self.repository = repository
    }

    func loadNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            notes = try await repository.fetchAll()
        } catch {
            errorMessage = "Impossible de charger les notes : \(error.localizedDescription)"
        }
        isLoading = false
    }

    func addNote(title: String, content: String) async {
        do {
            let note = try await repository.create(title: title, content: content)
            notes.insert(note, at: 0)
        } catch {
            errorMessage = "Impossible de créer la note : \(error.localizedDescription)"
        }
    }

    func deleteNotes(at offsets: IndexSet) async {
        for index in offsets {
            let note = notes[index]
            do {
                try await repository.delete(id: note.id)
                notes.removeAll { $0.id == note.id }
            } catch {
                errorMessage = "Impossible de supprimer la note : \(error.localizedDescription)"
            }
        }
    }
}

