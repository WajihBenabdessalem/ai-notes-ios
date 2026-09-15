import SwiftUI
import AINotesKit

struct NoteDetailView: View {
    @State private var viewModel: NoteDetailViewModel

    init(note: Note, container: AppContainer) {
        _viewModel = State(initialValue: NoteDetailViewModel(note: note, aiService: container.aiService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.note.content)
                    .font(.body)

                if let summary = viewModel.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Résumé IA", systemImage: "sparkles")
                            .font(.headline)
                        Text(summary)
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                Button {
                    Task { await viewModel.summarize() }
                } label: {
                    if viewModel.isSummarizing {
                        ProgressView()
                    } else {
                        Label("Résumer avec l'IA", systemImage: "sparkles")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSummarizing)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.note.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
