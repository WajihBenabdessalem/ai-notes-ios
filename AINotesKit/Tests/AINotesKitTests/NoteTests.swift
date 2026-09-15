import XCTest
@testable import AINotesKit

final class NoteTests: XCTestCase {
    func testNoteInitializationSetsProvidedValues() {
        let note = Note(title: "Titre", content: "Contenu")

        XCTAssertEqual(note.title, "Titre")
        XCTAssertEqual(note.content, "Contenu")
    }

    func testTwoNotesWithDifferentIDsAreNotEqual() {
        let a = Note(title: "A", content: "1")
        let b = Note(title: "A", content: "1")

        XCTAssertNotEqual(a, b) // les id générés diffèrent
    }
}
