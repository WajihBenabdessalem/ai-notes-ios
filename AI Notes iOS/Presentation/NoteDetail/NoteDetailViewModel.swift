import Foundation
import Observation
import AINotesKit

@MainActor
@Observable
final class NoteDetailViewModel {
    let note: Note
    private(set) var summary: String?
    private(set) var isSummarizing = false
    var errorMessage: String?

    private let summarizeNote: SummarizeNoteUseCase

    init(note: Note, aiService: AIService) {
        self.note = note
        self.summarizeNote = SummarizeNoteUseCase(aiService: aiService)
    }

    func summarize() async {
        isSummarizing = true
        errorMessage = nil
        do {
            summary = try await summarizeNote(noteID: note.id)
        } catch {
            errorMessage = "Impossible de résumer cette note : \(error.localizedDescription)"
        }
        isSummarizing = false
    }
}
