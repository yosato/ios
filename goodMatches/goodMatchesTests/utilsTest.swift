//
//  utilsTest.swift
//  goodMatchesTests
//
//  Created by Yo Sato on 18/10/2024.
//

import XCTest
@testable import goodMatches

final class utilsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
    
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func test_partitionBasedOrdering(){
        let listsOfEls=[([1,2,3,4,5],2)//one court, singles, two resting
                        ,([1,2,3,4,5],3)//one court, singles, three resting
                        ,([1,2,3,4,5,6],4)//one court, singles, four resting
                        ,([1,2,3,4,5],1)//one court, doubles, one resting
                        ,([1,2,3,4,5,6],2)//one court, doubles, two resting
                        ,([1,2,3,4,5,6,7],1)//two court, 1s1d, one resting
                        ,([1,2,3,4,5,6,7,8,9,10],2)// two courts, 2d, two resting
                        ,([1,2,3,4,5,6,7,8,9,10,11],3)// two courts, 2d, 3 resting
                        ]
        for (els,remainderCount) in listsOfEls{
//            let orderedParts=order_remainders_onPartition(elements:els, remainderCount:remainderCount)
            
        }
    }
    
    func testNetworkReachability(){
        let networkMonitor=NetworkMonitor()
        let realURLBool=networkMonitor.checkConnection(urlString:"http://satoama.co.uk")
        let fakeURLBool=networkMonitor.checkConnection(urlString:"http://satoamama.co.uk")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
