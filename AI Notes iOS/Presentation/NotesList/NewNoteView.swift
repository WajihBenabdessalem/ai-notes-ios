import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""

    let onSave: (String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Titre", text: $title)
                TextField("Contenu", text: $content, axis: .vertical)
                    .lineLimit(5...10)
            }
            .navigationTitle("Nouvelle note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        onSave(title, content)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
