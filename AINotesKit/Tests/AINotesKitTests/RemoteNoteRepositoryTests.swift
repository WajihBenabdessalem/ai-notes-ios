import XCTest
@testable import AINotesKit

final class RemoteNoteRepositoryTests: XCTestCase {
    private func makeRepository(
        handler: @escaping @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    ) -> RemoteNoteRepository {
        StubURLProtocol.handler = handler
        let client = URLSessionAPIClient(
            baseURL: URL(string: "https://example.com")!,
            session: StubURLProtocol.makeStubbedSession()
        )
        return RemoteNoteRepository(client: client)
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testFetchAllDecodesNoteList() async throws {
        let id = UUID()
        let repository = makeRepository { request in
            XCTAssertEqual(request.url?.path, "/notes")
            XCTAssertEqual(request.httpMethod, "GET")
            let json = """
            [{"id": "\(id.uuidString)", "title": "T", "content": "C", \
            "created_at": "2026-01-01T00:00:00Z"}]
            """
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }

        let notes = try await repository.fetchAll()

        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes[0].id, id)
        XCTAssertEqual(notes[0].title, "T")
    }

    func testCreateSendsPostRequestAndReturnsCreatedNote() async throws {
        let id = UUID()
        let repository = makeRepository { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let json = """
            {"id": "\(id.uuidString)", "title": "Nouveau", "content": "Contenu", \
            "created_at": "2026-01-01T00:00:00Z"}
            """
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }

        let note = try await repository.create(title: "Nouveau", content: "Contenu")

        XCTAssertEqual(note.title, "Nouveau")
        XCTAssertEqual(note.content, "Contenu")
    }

    func testDeleteSendsDeleteRequestToCorrectPath() async throws {
        let id = UUID()
        let repository = makeRepository { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertEqual(request.url?.path, "/notes/\(id.uuidString)")
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil
            )!
            return (response, Data())
        }

        try await repository.delete(id: id)
    }
}
