//
//  goodMatchesTests.swift
//  goodMatchesTests
//
//  Created by Yo Sato on 24/02/2024.
//

import XCTest
@testable import goodMatches

final class goodMatchesTests: XCTestCase {
    //var fakePlayers=[Player]()
//    let numbers=Array(0..<20)
//    let letters = Array("ABCDEFGHIJKLMNOPQRST")

//    for (letter,number) in myZip{
//        let gender=(true ? "male" : "female")
//        fakePlayers.append(Player(letter,number,gender))
//    }
    
        
//    let playersOnCourt=PlayersOnCourt.add_players(fakePlayers)
    
    var matchSetsOnCourt:MatchSetOnCourt!
    var begPlayers:[Player]!; var lowerIntPlayers:[Player]!;var upperIntPlayers:[Player]!; var advPlayers:[Player]!
    var outsideTeamPlayers:[Player]!
    var playersOnCourt5:PlayersOnCourt!;  var playersOnCourt6:PlayersOnCourt!; var playersOnCourt7:PlayersOnCourt!
    var playersOnCourt8:PlayersOnCourt!;  var playersOnCourt9:PlayersOnCourt!; var playersOnCourt10:PlayersOnCourt!
    var playersOnCourt11:PlayersOnCourt!;  var playersOnCourt12:PlayersOnCourt!;
    var aMatch:Match!
    var begTeam:Team!; var begTeam0:Team!; var intTeam:Team!; var advTeam:Team!
    var begIntTeam:Team!; var intAdvTeam:Team!; var begAdvTeam:Team!
    var singleBegTeam:Team!; var singleIntTeam:Team!
    var matchesD1S1:[Match]!; var matchesD2:[Match]!; var matchesD2S1:[Match]!
    var matchSetOnCourt6a:MatchSetOnCourt!; var matchSetOnCourt6b:MatchSetOnCourt!; var matchSetOnCourt6c:MatchSetOnCourt!
    var arraysOfInts:[[Int]]!
    var setOfPlayersOnCourt:[PlayersOnCourt]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        begPlayers=[Player(name:"a1",score:10,gender:"male",club:"Funabashi"), Player(name:"a2",score:20,gender:"male",club:"Funabashi"), Player(name:"a3",score:30,gender:"male",club:"Funabashi"), Player(name:"a4",score:30,gender:"male",club:"Funabashi"), Player(name:"a5",score:30,gender:"male",club:"Funabashi")]
        lowerIntPlayers=[Player(name:"b1",score:40,gender:"male",club:"Funabashi"), Player(name:"b2",score:45,gender:"male",club:"Funabashi"), Player(name:"b3",score:50,gender:"male",club:"Funabashi"), Player(name:"b4",score:50,gender:"male",club:"Funabashi"), Player(name:"b5",score:50,gender:"male",club:"Funabashi")]
        upperIntPlayers=[Player(name:"b6",score:55,gender:"male",club:"Funabashi"), Player(name:"b7",score:55,gender:"male",club:"Funabashi"), Player(name:"b8",score:55,gender:"male",club:"Funabashi"), Player(name:"b9",score:60,gender:"male",club:"Funabashi"), Player(name:"b10",score:60,gender:"male",club:"Funabashi")]
        advPlayers=[Player(name:"c1",score:70,gender:"male",club:"Funabashi"), Player(name:"c2",score:80,gender:"male",club:"Funabashi"), Player(name:"c3",score:90,gender:"male",club:"Funabashi"), Player(name:"c4",score:90,gender:"male",club:"Funabashi")]
        outsideTeamPlayers=[Player(name:"d1",score:40,gender:"male",club:"Funabashi"), Player(name:"d2",score:50,gender:"male",club:"Funabashi"), Player(name:"d3",score:60,gender:"male",club:"Funabashi"), Player(name:"d4",score:70,gender:"male",club:"Funabashi")]
        
        let players5=[begPlayers[0],lowerIntPlayers[0],lowerIntPlayers[1],upperIntPlayers[0],advPlayers[0]]
        
        playersOnCourt5=PlayersOnCourt();  playersOnCourt5.add_players(players5)
        
        playersOnCourt6=PlayersOnCourt(); let players6=players5+[upperIntPlayers[1]]; playersOnCourt6.add_players(players6)
        playersOnCourt7=PlayersOnCourt(); let players7=players6+[begPlayers[1]]; playersOnCourt7.add_players(players7)
        playersOnCourt8=PlayersOnCourt(); let players8=players7+[advPlayers[1]]; playersOnCourt8.add_players(players8)
        playersOnCourt9=PlayersOnCourt(); let players9=players8+[lowerIntPlayers[2]]; playersOnCourt9.add_players(players9)
        playersOnCourt10=PlayersOnCourt(); let players10=players9+[upperIntPlayers[2]]; playersOnCourt10.add_players(players10)
        playersOnCourt11=PlayersOnCourt(); let players11=players10+[advPlayers[2]]; playersOnCourt11.add_players(players11)
        playersOnCourt12=PlayersOnCourt(); let players12=players11+[lowerIntPlayers[3]]; playersOnCourt12.add_players(players12)
        //
        setOfPlayersOnCourt=[playersOnCourt5,playersOnCourt6,playersOnCourt7,playersOnCourt7,playersOnCourt8,playersOnCourt9,playersOnCourt10]
        //
        arraysOfInts=[[4,1],[4,2],[4,3],[4,2,1],[4,4],[4,4,1],[4,4,2]]



        begTeam=Team([begPlayers[0],begPlayers[1]])
        begTeam0=Team([begPlayers[2],begPlayers[3]])
        intTeam=Team([lowerIntPlayers[0],lowerIntPlayers[1]])
        advTeam=Team([advPlayers[0],advPlayers[1]])
//        begAdvTeam=Team([begPlayers[2],advPlayers[2]])
//        intAdvTeam=Team([lowerIntPlayers[2],advPlayers[3]])
//        begIntTeam=Team([begPlayers[3],lowerIntPlayers[3]])
//        singleBegTeam=Team([begPlayers[4]])
//        singleIntTeam=Team([lowerIntPlayers[4]])
//        matchesD1S1=[Match([begTeam,intTeam]),Match([singleBegTeam,singleIntTeam])]
//        matchSetOnCourt5=MatchSetOnCourt([Match([begTeam,intTeam])],restingPlayers: [outsideTeamPlayers[0]])
        matchSetOnCourt6a=MatchSetOnCourt([Match([begTeam,intTeam]),Match([Team([advPlayers[0]]),Team([advPlayers[1]])])],restingPlayers:[])
        matchSetOnCourt6b=MatchSetOnCourt([Match([begTeam,advTeam]),Match([Team([advPlayers[2]]),Team([advPlayers[3]])])],restingPlayers:[])
        matchSetOnCourt6c=MatchSetOnCourt([Match([begTeam0,advTeam]),Match([Team([advPlayers[1]]),Team([advPlayers[3]])])],restingPlayers:[])
//        matchSetOnCourt6_2=MatchSetOnCourt(matchesD1S1,restingPlayers:[])
//        matchSetOnCourt7_1=MatchSetOnCourt([Match([begTeam,intTeam])],restingPlayers:[outsideTeamPlayers[0],outsideTeamPlayers[1],outsideTeamPlayers[2]])
//        matchSetOnCourt7_2=MatchSetOnCourt(matchesD1S1,restingPlayers:[outsideTeamPlayers[0]])
//        matchSetOnCourt8=MatchSetOnCourt(matchesD2,restingPlayers:[])
//        matchSetOnCourt9=MatchSetOnCourt(matchesD2,restingPlayers:[outsideTeamPlayers[0]])
//        matchSetOnCourt10=MatchSetOnCourt(matchesD2S1,restingPlayers:[])
//        matchSetOnCourt11=MatchSetOnCourt(matchesD2S1,restingPlayers:[outsideTeamPlayers[0]])

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
    
    func test_count_partitions(){
        let intsCounts=[([4,1],5),([4,2],15),([4,3],35),([4,4],35),([4,4,1],315),([4,2,2],210),([4,4,2],1575),([4,4,4],5775)]
        for (ints,count) in intsCounts{
            let purportedCount=count_intpartitions(ints)
            print("\(ints) should be \(count) got \(purportedCount)")

            XCTAssert(count_intpartitions(ints)==count)
        }
        
    }
    
    func test_player_partitions(){
        for (playersOnCourt,ints) in zip(setOfPlayersOnCourt,arraysOfInts){
            let partitions=get_partitions_withIntegers(playersOnCourt.players, ints)
            let duplicateCount=count_order_variant_partitions(partitions)
            if duplicateCount>=1{print("\(duplicateCount) duplicates found")}
            XCTAssert(duplicateCount == 0)
            let countObtained=partitions.count
            let countExpected=count_intpartitions(ints)
            print("for \(ints), should be \(countExpected), got \(countObtained)")
            XCTAssert(countObtained==countExpected)
        }
    }
    
    func test_doublesTeamShared_p(){
        XCTAssert(doublesTeamShared_p(matchSetOnCourt6a, matchSetOnCourt6b))
        XCTAssert(doublesTeamShared_p(matchSetOnCourt6b, matchSetOnCourt6c))
        XCTAssert(!doublesTeamShared_p(matchSetOnCourt6a, matchSetOnCourt6c))
    }

    func test_singlesPlayerShared_p(){
        XCTAssert(!singlesPlayerShared_p(matchSetOnCourt6a, matchSetOnCourt6b))
        XCTAssert(singlesPlayerShared_p(matchSetOnCourt6b, matchSetOnCourt6c))
        XCTAssert(singlesPlayerShared_p(matchSetOnCourt6a, matchSetOnCourt6c))
    }

    func test_assign_courtTeamSize(){
        let sizeAnswerPairs=[((1,9),[4:1]),((1,6),[4:1]),((2,10),[4:2]),((2,6),[4:1,2:1]),((3,6),[2:3]),((2,7),[4:1,2:1]),((2,8),[4:2]),((2,9),[4:2]),((3,8),[4:1,2:2]),((3,9),[4:1,2:2]),((3,10),[4:2,2:1]),((3,11),[4:2,2:1]),((3,12),[4:3])]
        for ((courtCount,playerCount),answer) in sizeAnswerPairs{
            let proposed=assign_courtTeamsize(courtCount: courtCount, playerCount: playerCount)
            XCTAssert(proposed==answer)
        }
    }
    
    // cases with resting players

    func test_GoodMatchSetsOnCourt_get_good_matchsets6_1(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt6, 1)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        XCTAssert(fair)

    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets5(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt5, 1)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        XCTAssert(finalSets.count==15)
        let fair1=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        let fair2=goodMatchSetsOnCourt.intermatchset_constraints_observed(tipWindow: (5,2))
        
        XCTAssert(fair1)
        XCTAssert(fair2)
        
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets10_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt10, 2)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        XCTAssert(fair)
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets9(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt9, 2)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        XCTAssert(fair)
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets7_1(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt7, 1)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        XCTAssert(fair)
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets7_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt7, 2)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        XCTAssert(fair)

    }

//    func test_GoodMatchSetsOnCourt_get_good_matchsets11(){
//        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
//        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt11, 3)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)
//        
//    }
// currently taking too much time...
//    func test_GoodMatchSetsOnCourt_get_good_matchsets12(){
//        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
//        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt12, 3)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)
//        
//    }

    // cases without resting players

    func test_GoodMatchSetsOnCourt_get_good_matchsets6_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt6, 2)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets8(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt8, 2)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
    }

//    func test_Match_ordered(){
//        aMatch=Match([begTeam,intTeam])
//        XCTAssert(aMatch.teams.0.meanScore>aMatch.teams.1.meanScore)
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPerformance_get_best_matchsets() throws {
            self.measure {
                // Put the code you want to measure the time of here.
                let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
                goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt10, 2)
                //let finalSets=goodMatchSetsOnCourt.orderedMatchSets
            
        }
    }

}