import XCTest

@testable import HopTests

XCTMain([
    testCase(LexerTests.allTests),
    testCase(ParserErrorTests.allTests),
    testCase(TestModuleTests.allTests),
    testCase(ArrayClassTests.allTests)
    ])
