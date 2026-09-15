import SwiftUI
import AINotesKit

struct NotesListView: View {
    @State private var viewModel: NotesListViewModel
    @State private var showingNewNote = false
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: NotesListViewModel(repository: container.noteRepository))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(value: note) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title).font(.headline)
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .onDelete { offsets in
                    Task { await viewModel.deleteNotes(at: offsets) }
                }
            }
            .navigationTitle("Mes notes")
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note, container: container)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SearchView(container: container)
                    } label: {
                        Label("Recherche", systemImage: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink {
                            ChatView(container: container)
                        } label: {
                            Label("Assistant", systemImage: "message")
                        }
                        Button {
                            showingNewNote = true
                        } label: {
                            Label("Nouvelle note", systemImage: "plus")
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.notes.isEmpty {
                    ProgressView()
                } else if viewModel.notes.isEmpty {
                    ContentUnavailableView(
                        "Aucune note",
                        systemImage: "note.text",
                        description: Text("Ajoutez votre première note pour commencer.")
                    )
                }
            }
            .task { await viewModel.loadNotes() }
            .refreshable { await viewModel.loadNotes() }
            .sheet(isPresented: $showingNewNote) {
                NewNoteView { title, content in
                    Task { await viewModel.addNote(title: title, content: content) }
                }
            }
            .alert(
                "Erreur",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
                ),
                actions: { Button("OK") {} },
                message: { Text(viewModel.errorMessage ?? "") }
            )
        }
    }
}
