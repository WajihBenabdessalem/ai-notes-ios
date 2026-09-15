import XCTest
@testable import AINotesKit

final class RemoteAIServiceTests: XCTestCase {
    private func makeService(
        handler: @escaping @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    ) -> RemoteAIService {
        StubURLProtocol.handler = handler
        let client = URLSessionAPIClient(
            baseURL: URL(string: "https://example.com")!,
            session: StubURLProtocol.makeStubbedSession()
        )
        return RemoteAIService(client: client)
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testSummarizeReturnsSummaryFromResponse() async throws {
        let noteID = UUID()
        let service = makeService { request in
            XCTAssertEqual(request.url?.path, "/notes/\(noteID.uuidString)/summarize")
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(#"{"summary": "Résumé généré"}"#.utf8))
        }

        let summary = try await service.summarize(noteID: noteID)

        XCTAssertEqual(summary, "Résumé généré")
    }

    func testChatReturnsAnswerAndSourceIDs() async throws {
        let sourceID = UUID()
        let service = makeService { request in
            XCTAssertEqual(request.url?.path, "/chat")
            let json = """
            {"answer": "Réponse", "source_note_ids": ["\(sourceID.uuidString)"]}
            """
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }

        let result = try await service.chat(message: "Question")

        XCTAssertEqual(result.answer, "Réponse")
        XCTAssertEqual(result.sourceNoteIDs, [sourceID])
    }

    func testSearchReturnsScoredResults() async throws {
        let noteID = UUID()
        let service = makeService { request in
            XCTAssertEqual(request.url?.path, "/search")
            let json = """
            [{"note": {"id": "\(noteID.uuidString)", "title": "T", "content": "C", \
            "created_at": "2026-01-01T00:00:00Z"}, "score": 0.87}]
            """
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }

        let results = try await service.search(query: "congés")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].note.id, noteID)
        XCTAssertEqual(results[0].score, 0.87, accuracy: 0.0001)
    }
}
