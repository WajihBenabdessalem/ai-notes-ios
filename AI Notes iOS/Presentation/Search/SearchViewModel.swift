import Foundation
import Observation
import AINotesKit

@MainActor
@Observable
final class SearchViewModel {
    var query: String = ""
    private(set) var results: [SearchResult] = []
    private(set) var isSearching = false

    private let searchNotes: SearchNotesUseCase

    init(aiService: AIService) {
        self.searchNotes = SearchNotesUseCase(aiService: aiService)
    }

    func search() async {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            results = []
            return
        }
        isSearching = true
        results = (try? await searchNotes(query: text)) ?? []
        isSearching = false
    }
}
