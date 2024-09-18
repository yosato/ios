//
//  jankenModelsTests.swift
//  jankenModelsTests
//
//  Created by Yo Sato on 18/08/2024.
//

import XCTest
@testable import jankenModels
final class jankenModelTests: XCTestCase {
    
    var mockParticipants:[Participant] = []
    var twoPeopleSession:JankenBout=JankenBout([:])
    var threePeopleSession:JankenBout=JankenBout([:])

    override func setUpWithError() throws {
        for num in (1...10){
            mockParticipants.append(Participant(displayName: "name\(num)", email: "name\(num)@aaa.com"))
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJankenTwoPeople() throws {
        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.rock,  mockParticipants[1]:JankenHand.rock])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [])
        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.scissors,  mockParticipants[1]:JankenHand.scissors])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [])
        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.paper,  mockParticipants[1]:JankenHand.paper])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [])

        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.rock,  mockParticipants[1]:JankenHand.paper])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [mockParticipants[1]])

        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.rock,  mockParticipants[1]:JankenHand.scissors])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [mockParticipants[0]])

        twoPeopleSession=JankenBout([mockParticipants[0]:JankenHand.paper,  mockParticipants[1]:JankenHand.scissors])
        XCTAssert(twoPeopleSession.do_janken_and_get_winners() == [mockParticipants[1]])


    }
    func testJankenThreePeople() throws {
        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.rock,  mockParticipants[1]:JankenHand.rock, mockParticipants[2]:JankenHand.rock])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [])
        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.paper,  mockParticipants[1]:JankenHand.paper, mockParticipants[2]:JankenHand.paper])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [])
        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.scissors,  mockParticipants[1]:JankenHand.rock,mockParticipants[2]:JankenHand.paper])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [])

        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.rock,  mockParticipants[1]:JankenHand.rock, mockParticipants[2]:JankenHand.scissors])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [mockParticipants[0],mockParticipants[1]])
        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.paper,  mockParticipants[1]:JankenHand.scissors, mockParticipants[2]:JankenHand.paper])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [mockParticipants[1]])
        threePeopleSession=JankenBout([mockParticipants[0]:JankenHand.paper,  mockParticipants[1]:JankenHand.rock,mockParticipants[2]:JankenHand.rock])
        XCTAssert(threePeopleSession.do_janken_and_get_winners() == [mockParticipants[0]])


        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testJankenSeriesInGroup1() throws{
        let jankenSeries=JankenSeriesInGroup(groupMembers:Set(mockParticipants[0...6]))
        let jankenTree=jankenSeries.do_jankenSeries_in_group()
    }
    func testJankenSeriesInGroup2() throws{
        let jankenSeries=JankenSeriesInGroup(seriesTree:JankenTree(branches:jankenModels.fakeRoundsSmall))
        
    }

    func testMakingDrawnSessions() throws{
        for i in (2...8){
            let dSessions=DrawnBouts(participants:Set(mockParticipants[0...i]))
            
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
