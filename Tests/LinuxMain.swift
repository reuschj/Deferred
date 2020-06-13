import XCTest

import DeferredTests

var tests = [XCTestCaseEntry]()
tests += DeferredTests.allTests()
XCTMain(tests)
