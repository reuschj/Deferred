import XCTest
@testable import Deferred

final class DeferredTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Deferred().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
