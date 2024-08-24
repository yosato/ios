//
//  onlineJankenTests.swift
//  onlineJankenTests
//
//  Created by Yo Sato on 31/07/2024.
//

import XCTest
@testable import onlineJanken
@testable import jankenModels

final class onlineJankenTests: XCTestCase {
    var mockParticipants:[Participant]=[]

    override func setUpWithError() throws {
        for num in (1...5){
            mockParticipants.append(Participant(displayName: "name\(num)", email: "name\(num)@aaa.com"))
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJankenSeries() throws {
     
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
