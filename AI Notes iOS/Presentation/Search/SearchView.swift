import SwiftUI
import AINotesKit

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(container: AppContainer) {
        _viewModel = State(initialValue: SearchViewModel(aiService: container.aiService))
    }

    var body: some View {
        List(viewModel.results, id: \.note.id) { result in
            VStack(alignment: .leading, spacing: 4) {
                Text(result.note.title).font(.headline)
                Text(result.note.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                Text(String(format: "Pertinence : %.0f %%", result.score * 100))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .searchable(text: $viewModel.query, prompt: "Recherche sémantique...")
        .onChange(of: viewModel.query) {
            Task { await viewModel.search() }
        }
        .navigationTitle("Recherche")
        .overlay {
            if viewModel.isSearching {
                ProgressView()
            }
        }
    }
}
