import Foundation
import Observation
import AINotesKit

struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable { case user, assistant }

    let id = UUID()
    let role: Role
    let text: String
}

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var isSending = false
    var draft: String = ""

    private let sendChatMessage: SendChatMessageUseCase

    init(aiService: AIService) {
        self.sendChatMessage = SendChatMessageUseCase(aiService: aiService)
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(role: .user, text: text))
        draft = ""
        isSending = true

        do {
            let result = try await sendChatMessage(message: text)
            messages.append(ChatMessage(role: .assistant, text: result.answer))
        } catch {
            let message = "Désolé, une erreur est survenue : \(error.localizedDescription)"
            messages.append(ChatMessage(role: .assistant, text: message))
        }
        isSending = false
    }
}
