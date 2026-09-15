import XCTest
@testable import AINotesKit

final class APIClientTests: XCTestCase {
    private func makeClient() -> URLSessionAPIClient {
        URLSessionAPIClient(
            baseURL: URL(string: "https://example.com")!,
            session: StubURLProtocol.makeStubbedSession()
        )
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testSendDecodesSuccessfulResponse() async throws {
        struct Payload: Decodable, Equatable { let value: String }

        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            let data = try JSONEncoder().encode(Payload(value: "ok"))
            return (response, data)
        }

        let result: Payload = try await makeClient().send(APIEndpoint(path: "/test", method: .get))

        XCTAssertEqual(result, Payload(value: "ok"))
    }

    func testSendThrowsServerErrorOnNon2xxStatus() async {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil
            )!
            return (response, Data("Internal error".utf8))
        }

        do {
            let _: EmptyDecodable = try await makeClient().send(APIEndpoint(path: "/test", method: .get))
            XCTFail("Une erreur aurait dû être levée")
        } catch APIError.server(let statusCode, let message) {
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(message, "Internal error")
        } catch {
            XCTFail("Erreur inattendue : \(error)")
        }
    }

    func testSendThrowsDecodingErrorOnMalformedJSON() async {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data("not json".utf8))
        }

        do {
            let _: EmptyDecodable = try await makeClient().send(APIEndpoint(path: "/test", method: .get))
            XCTFail("Une erreur aurait dû être levée")
        } catch APIError.decoding {
            // succès attendu
        } catch {
            XCTFail("Erreur inattendue : \(error)")
        }
    }

    func testSendNoContentSucceedsOn204() async throws {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil
            )!
            return (response, Data())
        }

        try await makeClient().sendNoContent(APIEndpoint(path: "/notes/abc", method: .delete))
        // Ne doit pas lever d'erreur.
    }
}

private struct EmptyDecodable: Decodable {}
