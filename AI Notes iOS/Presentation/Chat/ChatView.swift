import SwiftUI
import AINotesKit

struct ChatView: View {
    @State private var viewModel: ChatViewModel

    init(container: AppContainer) {
        _viewModel = State(initialValue: ChatViewModel(aiService: container.aiService))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("Poser une question sur vos notes...", text: $viewModel.draft)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await viewModel.send() }
                } label: {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(
                    viewModel.isSending
                        || viewModel.draft.trimmingCharacters(in: .whitespaces).isEmpty
                )
            }
            .padding()
        }
        .navigationTitle("Assistant IA")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.text)
                .padding(10)
                .background(message.role == .user ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
