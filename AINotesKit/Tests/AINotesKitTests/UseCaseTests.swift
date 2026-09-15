import XCTest
@testable import AINotesKit

private struct MockAIService: AIService {
    var summarizeResult: Result<String, Error> = .success("résumé")
    var searchResult: Result<[SearchResult], Error> = .success([])
    var chatResult: Result<ChatResult, Error> = .success(ChatResult(answer: "", sourceNoteIDs: []))

    func summarize(noteID: UUID) async throws -> String {
        try summarizeResult.get()
    }

    func search(query: String) async throws -> [SearchResult] {
        try searchResult.get()
    }

    func chat(message: String) async throws -> ChatResult {
        try chatResult.get()
    }
}

private struct DummyError: Error {}

final class SummarizeNoteUseCaseTests: XCTestCase {
    func testReturnsSummaryFromService() async throws {
        let useCase = SummarizeNoteUseCase(
            aiService: MockAIService(summarizeResult: .success("Résumé du texte."))
        )

        let result = try await useCase(noteID: UUID())

        XCTAssertEqual(result, "Résumé du texte.")
    }

    func testPropagatesServiceError() async {
        let useCase = SummarizeNoteUseCase(aiService: MockAIService(summarizeResult: .failure(DummyError())))

        do {
            _ = try await useCase(noteID: UUID())
            XCTFail("Une erreur aurait dû être levée")
        } catch is DummyError {
            // succès attendu
        } catch {
            XCTFail("Erreur inattendue : \(error)")
        }
    }
}

final class SearchNotesUseCaseTests: XCTestCase {
    func testReturnsResultsFromService() async throws {
        let note = Note(title: "Congés", content: "25 jours")
        let useCase = SearchNotesUseCase(
            aiService: MockAIService(searchResult: .success([SearchResult(note: note, score: 0.9)]))
        )

        let results = try await useCase(query: "congés")

        XCTAssertEqual(results.map(\.note.id), [note.id])
    }
}

final class SendChatMessageUseCaseTests: XCTestCase {
    func testReturnsChatResultFromService() async throws {
        let expected = ChatResult(answer: "Réponse", sourceNoteIDs: [UUID()])
        let useCase = SendChatMessageUseCase(aiService: MockAIService(chatResult: .success(expected)))

        let result = try await useCase(message: "Question")

        XCTAssertEqual(result, expected)
    }
}
