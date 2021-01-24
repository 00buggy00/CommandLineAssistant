import XCTest
@testable import CommandLineAssistant

final class CommandLineAssistantTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CommandLineAssistant().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
