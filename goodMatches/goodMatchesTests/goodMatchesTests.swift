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
    var sameStrengthPlayers_beg:[Player]!; var sameStrengthPlayers_adv:[Player]!
    var playersOnCourt4:PlayersOnCourt!; var playersOnCourt5:PlayersOnCourt!;  var playersOnCourt6:PlayersOnCourt!; var playersOnCourt7:PlayersOnCourt!
    var playersOnCourt8:PlayersOnCourt!;  var playersOnCourt9:PlayersOnCourt!; var playersOnCourt10:PlayersOnCourt!
    var playersOnCourt11:PlayersOnCourt!;  var playersOnCourt12:PlayersOnCourt!; var playersOnCourt13:PlayersOnCourt!; var playersOnCourt14:PlayersOnCourt!
    var playersOnCourt15:PlayersOnCourt!
    var playersOnCourt16:PlayersOnCourt!; var playersOnCourt17:PlayersOnCourt!;  var playersOnCourt18:PlayersOnCourt!; var playersOnCourt19:PlayersOnCourt!
    var playersOnCourt20:PlayersOnCourt!

    var aMatch:Match!
    var begTeam:Team!; var begTeam0:Team!; var intTeam:Team!; var advTeam:Team!
    var begIntTeam:Team!; var intAdvTeam:Team!; var begAdvTeam:Team!
    var sameStrTeams_begD:[Team]!; var sameStrTeam_beg1s:Team!;var sameStrTeam_adv1s:Team!;var sameStrTeam_adv2s:Team!; var sameStrTeam_beg2s:Team!; var sameStrTeams_begadvD:[Team]!
    var veryStrongTeams:[Team]!; var veryWeakTeams:[Team]!
    var singleBegTeam:Team!; var singleIntTeam:Team!
    var matchesD1S1:[Match]!; var matchesD2:[Match]!; var matchesD2S1:[Match]!
    var matchSetOnCourt6a:MatchSetOnCourt!; var matchSetOnCourt6b:MatchSetOnCourt!; var matchSetOnCourt6c:MatchSetOnCourt!
    var arraysOfInts:[[Int]]!
    var setOfPlayersOnCourt:[PlayersOnCourt]!

    func players_all_distinct(_ players:[Player])->Bool{
        var seenPlayerIDs=Set<String>()
        for player in players{
            let playerID=player.id
            if(seenPlayerIDs.contains(playerID)){
                return false
            }else{seenPlayerIDs.insert(playerID)}
        }
        return true
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        veryStrongTeams=[
            Team([Player(name:"strong1",score:99,gender:"male",club:"Funabashi"),Player(name:"strong2",score:99,gender:"male",club:"Funabashi")])
       ,           Team([Player(name:"strong3",score:99,gender:"male",club:"Funabashi"),Player(name:"strong4",score:99,gender:"male",club:"Funabashi")])
        ]
        veryWeakTeams=[
            Team([Player(name:"strong1",score:1,gender:"male",club:"Funabashi"),Player(name:"strong2",score:1,gender:"male",club:"Funabashi")])
       ,           Team([Player(name:"strong3",score:1,gender:"male",club:"Funabashi"),Player(name:"strong4",score:1,gender:"male",club:"Funabashi")])
        ]
        
        begPlayers=[Player(name:"a1",score:10,gender:"male",club:"Funabashi"), Player(name:"a2",score:20,gender:"male",club:"Funabashi"), Player(name:"a3",score:30,gender:"male",club:"Funabashi"), Player(name:"a4",score:30,gender:"male",club:"Funabashi"), Player(name:"a5",score:30,gender:"male",club:"Funabashi")]
        lowerIntPlayers=[Player(name:"b1",score:40,gender:"male",club:"Funabashi"), Player(name:"b2",score:45,gender:"male",club:"Funabashi"), Player(name:"b3",score:50,gender:"male",club:"Funabashi"), Player(name:"b4",score:50,gender:"male",club:"Funabashi"), Player(name:"b5",score:50,gender:"male",club:"Funabashi")]
        upperIntPlayers=[Player(name:"b6",score:55,gender:"male",club:"Funabashi"), Player(name:"b7",score:55,gender:"male",club:"Funabashi"), Player(name:"b8",score:55,gender:"male",club:"Funabashi"), Player(name:"b9",score:60,gender:"male",club:"Funabashi"), Player(name:"b10",score:60,gender:"male",club:"Funabashi")]
        advPlayers=[Player(name:"c1",score:70,gender:"male",club:"Funabashi"), Player(name:"c2",score:80,gender:"male",club:"Funabashi"), Player(name:"c3",score:90,gender:"male",club:"Funabashi"), Player(name:"c4",score:90,gender:"male",club:"Funabashi"), Player(name:"c5",score:90,gender:"male",club:"Funabashi")]
        outsideTeamPlayers=[Player(name:"d1",score:40,gender:"male",club:"Funabashi"), Player(name:"d2",score:50,gender:"male",club:"Funabashi"), Player(name:"d3",score:60,gender:"male",club:"Funabashi"), Player(name:"d4",score:70,gender:"male",club:"Funabashi")]
        sameStrengthPlayers_beg=[Player(name:"sb1",score:20,gender:"male",club:"Funabashi"), Player(name:"sb2",score:20,gender:"male",club:"Funabashi"), Player(name:"sb3",score:20,gender:"male",club:"Funabashi"), Player(name:"sb4",score:20,gender:"male",club:"Funabashi"),
            Player(name:"sb5",score:20,gender:"male",club:"Funabashi"),
            Player(name:"sb6",score:20,gender:"male",club:"Funabashi")]
        sameStrengthPlayers_adv=[Player(name:"sa1",score:80,gender:"male",club:"Funabashi"), Player(name:"sa2",score:80,gender:"male",club:"Funabashi"), Player(name:"sa3",score:80,gender:"male",club:"Funabashi"), Player(name:"sa4",score:80,gender:"male",club:"Funabashi"),
                                 Player(name:"sa5",score:80,gender:"male",club:"Funabashi"), Player(name:"sa6",score:80,gender:"male",club:"Funabashi")]

        let players4=[begPlayers[0],lowerIntPlayers[0],lowerIntPlayers[1],upperIntPlayers[0]]
        let players5=players4+[advPlayers[0]]
        assert(players_all_distinct(players5))
        
        playersOnCourt4=PlayersOnCourt();  playersOnCourt4.add_players(players4)
        playersOnCourt5=PlayersOnCourt();  playersOnCourt5.add_players(players5)

        playersOnCourt6=PlayersOnCourt(); let players6=players5+[upperIntPlayers[1]]; assert(players_all_distinct(players6)); playersOnCourt6.add_players(players6)
        playersOnCourt7=PlayersOnCourt(); let players7=players6+[begPlayers[1]]; assert(players_all_distinct(players7)); playersOnCourt7.add_players(players7)
        playersOnCourt8=PlayersOnCourt(); let players8=players7+[advPlayers[1]]; assert(players_all_distinct(players8)); playersOnCourt8.add_players(players8)
        playersOnCourt9=PlayersOnCourt(); let players9=players8+[lowerIntPlayers[2]]; assert(players_all_distinct(players9)); playersOnCourt9.add_players(players9)
        playersOnCourt10=PlayersOnCourt(); let players10=players9+[upperIntPlayers[2]]; assert(players_all_distinct(players10)); playersOnCourt10.add_players(players10)
        playersOnCourt11=PlayersOnCourt(); let players11=players10+[advPlayers[2]];  assert(players_all_distinct(players11)); playersOnCourt11.add_players(players11)
        playersOnCourt12=PlayersOnCourt(); let players12=players11+[lowerIntPlayers[3]];  assert(players_all_distinct(players12)); playersOnCourt12.add_players(players12)
        playersOnCourt13=PlayersOnCourt(); let players13=players12+[begPlayers[2]]; assert(players_all_distinct(players13)); playersOnCourt13.add_players(players13)
        playersOnCourt14=PlayersOnCourt(); let players14=players13+[upperIntPlayers[3]]; assert(players_all_distinct(players14)); playersOnCourt14.add_players(players14)
        playersOnCourt15=PlayersOnCourt(); let players15=players14+[upperIntPlayers[4]]; assert(players_all_distinct(players15)); playersOnCourt15.add_players(players15)
        playersOnCourt16=PlayersOnCourt(); let players16=players15+[lowerIntPlayers[4]]; assert(players_all_distinct(players16)); playersOnCourt16.add_players(players16)
        playersOnCourt17=PlayersOnCourt(); let players17=players16+[advPlayers[3]]; assert(players_all_distinct(players17)); playersOnCourt17.add_players(players17)
        playersOnCourt18=PlayersOnCourt(); let players18=players17+[begPlayers[3]]; assert(players_all_distinct(players18)); playersOnCourt18.add_players(players18)
        playersOnCourt19=PlayersOnCourt(); let players19=players18+[begPlayers[4]]; assert(players_all_distinct(players19)); playersOnCourt19.add_players(players19)
        playersOnCourt20=PlayersOnCourt(); let players20=players19+[advPlayers[4]]; assert(players_all_distinct(players20)); playersOnCourt20.add_players(players20)
        //
        setOfPlayersOnCourt=[playersOnCourt5,playersOnCourt6,playersOnCourt7,playersOnCourt7,playersOnCourt8,playersOnCourt9,playersOnCourt10]
        //
        arraysOfInts=[[4,1],[4,2],[4,3],[4,2,1],[4,4],[4,4,1],[4,4,2]]



        begTeam=Team([begPlayers[0],begPlayers[1]])
        begTeam0=Team([begPlayers[2],begPlayers[3]])
        intTeam=Team([lowerIntPlayers[0],lowerIntPlayers[1]])
        advTeam=Team([advPlayers[0],advPlayers[1]])
        sameStrTeams_begD=[Team([sameStrengthPlayers_beg[0],sameStrengthPlayers_beg[1]]),Team([sameStrengthPlayers_beg[2],sameStrengthPlayers_beg[3]])]
        sameStrTeams_begadvD=[Team([sameStrengthPlayers_beg[0],sameStrengthPlayers_adv[0]]),Team([sameStrengthPlayers_beg[1],sameStrengthPlayers_adv[1]])]
        sameStrTeam_beg1s=Team([sameStrengthPlayers_beg[4]])
        sameStrTeam_beg2s=Team([sameStrengthPlayers_beg[5]])
        sameStrTeam_adv1s=Team([sameStrengthPlayers_adv[4]])
        sameStrTeam_adv2s=Team([sameStrengthPlayers_adv[5]])
//        begAdvTeam=Team([begPlayers[2],advPlayers[2]])
//        intAdvTeam=Team([lowerIntPlayers[2],advPlayers[3]])
//        begIntTeam=Team([begPlayers[3],lowerIntPlayers[3]])
//        singleBegTeam=Team([begPlayers[4]])
//        singleIntTeam=Team([lowerIntPlayers[4]])
//        matchesD1S1=[Match([begTeam,intTeam]),Match([singleBegTeam,singleIntTeam])]
//        matchSetOnCourt5=MatchSetOnCourt([Match([begTeam,intTeam])],restingPlayerSet: [outsideTeamPlayers[0]])
        matchSetOnCourt6a=MatchSetOnCourt([Match([begTeam,intTeam]),Match([Team([advPlayers[0]]),Team([advPlayers[1]])])],restingPlayerSet:PlayerSet([]))
        matchSetOnCourt6b=MatchSetOnCourt([Match([begTeam,advTeam]),Match([Team([advPlayers[2]]),Team([advPlayers[3]])])],restingPlayerSet:PlayerSet([]))
        matchSetOnCourt6c=MatchSetOnCourt([Match([begTeam0,advTeam]),Match([Team([advPlayers[1]]),Team([advPlayers[3]])])],restingPlayerSet:PlayerSet([]))
//        matchSetOnCourt6_2=MatchSetOnCourt(matchesD1S1,restingPlayerSet:[])
//        matchSetOnCourt7_1=MatchSetOnCourt([Match([begTeam,intTeam])],restingPlayerSet:[outsideTeamPlayers[0],outsideTeamPlayers[1],outsideTeamPlayers[2]])
//        matchSetOnCourt7_2=MatchSetOnCourt(matchesD1S1,restingPlayerSet:[outsideTeamPlayers[0]])
//        matchSetOnCourt8=MatchSetOnCourt(matchesD2,restingPlayerSet:[])
//        matchSetOnCourt9=MatchSetOnCourt(matchesD2,restingPlayerSet:[outsideTeamPlayers[0]])
//        matchSetOnCourt10=MatchSetOnCourt(matchesD2S1,restingPlayerSet:[])
//        matchSetOnCourt11=MatchSetOnCourt(matchesD2S1,restingPlayerSet:[outsideTeamPlayers[0]])

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
    
    func test_get_partitions_withIntegers(){
        let elsIntsPair=[
            (["a","b","c","d"],[2,2])//4,2
//            ,(["a","b","c","d","e"],[2,2])//5,2
//            ,(["a","b","c","d","e","f"],[2,2,2])//6,3
//            ,(["a","b","c","d","e","f","g"],[2,2,2])//7,3
//            ,(["a","b","c","d","e","f"],[4,2])//6,2
//            ,(["a","b","c","d","e","f","g"],[4,2])//7,2
////                         ,(["a","b","c","d","e","f"],[3,3])
//            ,(["a","b","c","d","e","f","g","h"],[4,4])//8,2
//            ,(["a","b","c","d","e","f","g","h"],[4,2,2])//8,3
//            ,(["a","b","c","d","e","f","g","h","i"],[4,4])//9,2
//            ,(["a","b","c","d","e","f","g","h","i","j"],[4,4,2])//10,3
        ]
        let elsIntsPair_l=[
            (["a","b","c","d","e","f","g","h","i","j","k"],[4,4,2])//11,3
            ,(["a","b","c","d","e","f","g","h","i","j","k","l"],[4,4,4])//12,3
            ,(["a","b","c","d","e","f","g","h","i","j","k","l"],[2,2,4,4])//12,4
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m"],[4,4,4])//13,3
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n"],[2,4,4,4])//14,4
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o"],[2,4,4,4])//15,4
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"],[4,4,4,4])//16,4
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q"],[4,4,4,4])//17,4
]
        let elsIntsPair_vl=[
            (["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r"],[4,4,4,4])//18,4
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s"],[4,4,4,4,2])//19,5
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t"],[4,4,4,4,4])//20,5
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v"],[4,4,4,4,4])//22,5
            ,(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x"],[4,4,4,4,4,4])//24,6

]
        for (els,ints) in elsIntsPair{
            let remainder=els.count-ints.reduce(0,+)
            let expectedCount=count_intpartitions(ints,remainder: remainder)
            print("\(els) \(ints) expected \(expectedCount)")
            let partitionsWithRemainder0=get_partitions_withIntegers(Set(els), ints, doPotentiallyRandomPrune: false, debug:true)
            XCTAssert(expectedCount==partitionsWithRemainder0.count)
            //let partitionsWithRemainder=get_partitions_withIntegers(els, ints, doPotentiallyRandomPrune: false, debug:true)
            //XCTAssert(expectedCount==partitionsWithRemainder.count)
        }
        for (els,ints) in elsIntsPair_l{
            print(ints)
            print("remainder: \(els.count-ints.reduce(0,+))")
            let startTime=Date()
            let sizedSets=set2SizedSets(Set(els), ints:ints)
       //     let partitions=generate_distinct_paritions_withIntegers_withRemainderHoldout_withSizedSets(Set(els), ints: ints, sizedSets:sizedSets)
            print(Date().timeIntervalSince(startTime))
            print()
        }
//            let remainder=els.count-ints.reduce(0,+)
//            let expectedCount=count_intpartitions(ints,remainder: remainder)
//            print("\(els) \(ints)"+(remainder == 0 ? "" : " remainder \(remainder)")+" expected \(expectedCount)")
//            let startTime=Date()
//            //print(startTime)
//            let partitionsWithRemainder0=get_partitions_withIntegers0(Set(els), ints, doPotentiallyRandomPrune: false, debug:false)
//            XCTAssert(expectedCount==partitionsWithRemainder0.count)
//            let endTime=Date()
//            let timeElapsed=endTime.timeIntervalSince(startTime)
//            //print(endTime)
//            print("time taken \(String(format:"%.2f",timeElapsed))",terminator:"\n\n")
//        }
    }
    
//    func test_player_partitions(){
//        for (playersOnCourt,ints) in zip(setOfPlayersOnCourt,arraysOfInts){
//            let partitions=get_partitions_withIntegers(playersOnCourt.players, ints)
//            let duplicateCount=count_order_variant_partitions(partitions)
//            if duplicateCount>=1{print("\(duplicateCount) duplicates found")}
//            XCTAssert(duplicateCount == 0)
//            let countObtained=partitions.count
//            let countExpected=count_intpartitions(ints)
//            print("for \(ints), should be \(countExpected), got \(countObtained)")
//            XCTAssert(countObtained==countExpected)
//        }
//    }
    
    func test_matchscore_same_across_sizes(){
        let sameStrMatch_begS1=Match([sameStrTeam_beg1s,sameStrTeam_beg2s])
        let sameStrMatch_begS2=Match([sameStrTeam_beg1s,sameStrTeam_beg2s])
        let sameStrMatch_begD1=Match([sameStrTeams_begD[0],sameStrTeams_begD[1]])
        XCTAssert(sameStrMatch_begS1.scoreDiff==sameStrMatch_begD1.scoreDiff)
        let matchSetOnCourt=MatchSetOnCourt([sameStrMatch_begS1,sameStrMatch_begS2],restingPlayerSet:PlayerSet([]))
        XCTAssert(sameStrMatch_begS1.scoreDiff==matchSetOnCourt.totalScoreDiff)
    }
    func test_matchscore_average(){
        let sameStrMatch_S1=Match([sameStrTeam_beg1s,sameStrTeam_adv1s])
        let sameStrMatch_S2=Match([sameStrTeam_beg1s,sameStrTeam_adv2s])
        let matchSetOnCourt=MatchSetOnCourt([sameStrMatch_S1,sameStrMatch_S2],restingPlayerSet:PlayerSet([]))
        XCTAssert((sameStrMatch_S1.scoreDiff+sameStrMatch_S2.scoreDiff)/2.0==matchSetOnCourt.totalScoreDiff)
    }

    func test_doublesTeamShared_p(){
        XCTAssert(doublesTeamShared_p(matchSetOnCourt6a, matchSetOnCourt6b))
        XCTAssert(doublesTeamShared_p(matchSetOnCourt6b, matchSetOnCourt6c))
        XCTAssert(!doublesTeamShared_p(matchSetOnCourt6a, matchSetOnCourt6c))
    }

//    func test_singlesPlayerShared_p(){
//        XCTAssert(!singlesPlayerShared_p(matchSetOnCourt6a, matchSetOnCourt6b))
//        XCTAssert(singlesPlayerShared_p(matchSetOnCourt6b, matchSetOnCourt6c))
//        XCTAssert(singlesPlayerShared_p(matchSetOnCourt6a, matchSetOnCourt6c))
//    }

    func test_assign_courtTeamSize(){
        let sizeAnswerPairs=[((1,9),[4:1]),((1,6),[4:1]),((2,10),[4:2]),((2,6),[4:1,2:1]),((3,6),[2:3]),((2,7),[4:1,2:1]),((2,8),[4:2]),((2,9),[4:2]),((3,8),[4:1,2:2]),((3,9),[4:1,2:2]),((3,10),[4:2,2:1]),((3,11),[4:2,2:1]),((3,12),[4:3])]
        for ((courtCount,playerCount),answer) in sizeAnswerPairs{
            let proposed=assign_courtTeamsize(courtCount: courtCount, playerCount: playerCount)
            XCTAssert(proposed==answer)
        }
    }
    
    // cases without resting players, up to 10
    
    func tests_uptoNthMSFinish(_ listOfPairs:[(PlayersOnCourt,Int)], _ nth:Int){
        var prevMS:MatchSetOnCourt?=nil
        for (playersOnCourt,courtCount) in listOfPairs{
            let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
            print("\(playersOnCourt.players.count) players for \(courtCount) courts")
            for i in (0..<nth){
                if(i==0){
                    //initialising, get first MS
                    assert(goodMatchSetsOnCourt.orderedMatchSets.count==0)
                    goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt, courtCount)
                    assert(goodMatchSetsOnCourt.restingPlayerKeyedMatchSets!.nextUnfinishedRPSet==goodMatchSetsOnCourt.restingPlayerKeyedMatchSets!.partitionBasedRestingPlayerSetList[0])
                    assert(goodMatchSetsOnCourt.restingPlayerKeyedMatchSets!.chosenForwardInd==0)
                    assert(goodMatchSetsOnCourt.orderedMatchSets.count==1)}
                
                let currentMS=goodMatchSetsOnCourt.orderedMatchSets.last!
                print("round \(i+1)")
                currentMS.pretty_print()

                var matchResults=[MatchResult]()
                for match in currentMS.matchesOnCourt{
                    matchResults.append(MatchResult(matchSetInd:0,match:match,scores:(2,6)))
                }
                let matchSetResult=MatchSetResult(matchResults: matchResults)
                let gainsLosses=playersOnCourt.update_playerscores_matchSetResult(matchSetResult)
                

                if(prevMS != nil){
                    assert(currentMS != prevMS)}
                print(gainsLosses)
                print("done, diff changed to (unless draw) \(currentMS.totalScoreDiff)")
                
                // for asserting purposes
                prevMS=currentMS
                //1. update rpMSs (order in particular), 2. get new tip MS, ideally constraint-abiding
                let changed=goodMatchSetsOnCourt.update_matchsets_onResult()
                if(changed!){print("MS order changed")}else{print("MS order not changed")}
                if(goodMatchSetsOnCourt.playingRestingPlayerCounts!.1 != 0){assert(goodMatchSetsOnCourt.restingPlayerKeyedMatchSets!.nextUnfinishedRPSet==goodMatchSetsOnCourt.restingPlayerKeyedMatchSets!.partitionBasedRestingPlayerSetList[i+1])}
                assert(goodMatchSetsOnCourt.orderedMatchSets.count==i+2)
                let nextMS=goodMatchSetsOnCourt.orderedMatchSets.last!
                if(i==nth){print("next match (round \(i+2)):")
                    nextMS.pretty_print()}
            }
        }
    }


    func tests_uptoSecondMS_simpler_noRestingPlayers(){
        tests_uptoNthMSFinish([
            (playersOnCourt6,2) // 1d,1s
            ,(playersOnCourt8,2) // 2d
            ,(playersOnCourt8,3) // 1d,2s
            ,(playersOnCourt8,4) // 4s
            ,(playersOnCourt10,3) // 2d,1s
        ],2)
    }
    func tests_uptoSecondMS_simpler_withRestingPlayers(){
        tests_uptoNthMSFinish([
            (playersOnCourt5,1) // 1d,1rp
            ,(playersOnCourt7,1) // 1d,3rp
            ,(playersOnCourt7,2) // 1d,1s,1rp
            ,(playersOnCourt9,2) // 2d,1rp
            ,(playersOnCourt10,2) // 2d,2rp
        ],2)
    }
    func tests_uptoSecondMS_complex_noRestingPlayers(){
        tests_uptoNthMSFinish([
            (playersOnCourt10,4) // 1d,3s
            ,(playersOnCourt12,3) // 3d
            ,(playersOnCourt12,4) // 2d,2s
            ,(playersOnCourt14,4) // 3d,1s
            ,(playersOnCourt14,5) // 3d,2s
            ,(playersOnCourt16,4) // 4d
        ],2)
    }
    func tests_uptoSecondMS_complex_withRestingPlayers(){
        tests_uptoNthMSFinish([
            (playersOnCourt11,3) // 2d,1s,1rp
            ,(playersOnCourt13,3) // 3d,1rp
            ,(playersOnCourt15,4) // 3d,1s,1rp
            ,(playersOnCourt17,4) // 4d,1rp
            ,(playersOnCourt18,4) // 4d,2rp
        ],2)
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets4_1(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt4, 1)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets4_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt4, 2)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets6(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt6, 2)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets8(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt8, 2)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets10(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt10, 3)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }

    
    
    // cases with resting players
    // 2 players resting out of six
    func test_GoodMatchSetsOnCourt_get_good_matchsets6_1(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt6, 1)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }
    // 1 player resting out of five
    func test_GoodMatchSetsOnCourt_get_good_matchsets5(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt5, 1)
        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        XCTAssert(finalSets.count==15)
//        let fair1=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
////        let fair2=goodMatchSetsOnCourt.intermatchset_constraints_observed(tipWindow: (5,2))
//        
//        XCTAssert(fair1)
//        XCTAssert(fair2)
        
    }
    // 2 resting out of 10
    func test_GoodMatchSetsOnCourt_get_good_matchsets10_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt10, 2)
       // let finalSets=goodMatchSetsOnCourt.orderedMatchSets
       // let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
       // XCTAssert(fair)
    }
    // 1 resting out of 9
    func test_GoodMatchSetsOnCourt_get_good_matchsets9(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt9, 2)
        //let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //XCTAssert(fair)
    }
    // 3 resting out of 7
    func test_GoodMatchSetsOnCourt_get_good_matchsets7_1(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt7, 1)
        //let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //XCTAssert(fair)
    }
    // 1 resting out of 7
    func test_GoodMatchSetsOnCourt_get_good_matchsets7_2(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt7, 2)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)

    }

    // more than 10 players, divisible ones first
    func test_GoodMatchSetsOnCourt_get_good_matchsets12(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt12, 3)
//        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
//        XCTAssert(fair)
//
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets14(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt14, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets16(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt16, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets18(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt18, 5)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets20(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt20, 5)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }

    // with remainders
    
    
    func test_GoodMatchSetsOnCourt_get_good_matchsets11(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt11, 3)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }


    func test_GoodMatchSetsOnCourt_get_good_matchsets13(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt13, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets14_3(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt14, 3)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets15_4(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt15, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets15_3(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt15, 3)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets17(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt17, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }
    func test_GoodMatchSetsOnCourt_get_good_matchsets18_4(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt18, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }

    func test_GoodMatchSetsOnCourt_get_good_matchsets19(){
        let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
        goodMatchSetsOnCourt.get_best_new_matchset(playersOnCourt19, 4)
        //        let finalSets=goodMatchSetsOnCourt.orderedMatchSets
        //        let fair=goodMatchSetsOnCourt.restPlayer_fairly_ordered()
        //        XCTAssert(fair)
    }





    func url_connection_checking(){
        XCTAssert(!verifyUrl(urlString: "http://nonsense"))
        //address valid, but server not up
                  
    }
    
    func test_data_handling(){
        //deleting, remote / local
        
        //adding
        //changing
    }
    
    func test_elo_integrity(){
        //sum of the scores will be constant with a set of members, increases only when a member is added, by the member's score. mean score*members gives the total
        //drawing doesn't earn anything
        XCTAssert(get_elo_update_value(winningTeam:sameStrTeams_begD[0], against:sameStrTeams_begadvD[0], result:(4,4))==0.0)
        //winning against a stronger opponent earns more than against a weaker one
        let predictedResult=get_elo_update_value(winningTeam:sameStrTeams_begadvD[0], against:sameStrTeams_begD[0], result:(6,3))
        let upsetResult=get_elo_update_value(winningTeam:sameStrTeams_begD[0], against:sameStrTeams_begadvD[0], result:(6,3))
        XCTAssert(predictedResult<upsetResult)

        //winning with a larger margin earns more than with a smaller one
        let largerMarginResult=get_elo_update_value(winningTeam:sameStrTeams_begadvD[0], against:sameStrTeams_begD[0], result:(6,1))
        let smallerMarginResult=get_elo_update_value(winningTeam:sameStrTeams_begadvD[0], against:sameStrTeams_begD[0], result:(6,4))
        XCTAssert(smallerMarginResult<largerMarginResult)

        //score should not go over 100 or under 0
        XCTAssert(get_elo_update_value(winningTeam:veryStrongTeams[0], against: veryStrongTeams[1], result:(6,0))<100)
        XCTAssert(get_elo_update_value(winningTeam:veryWeakTeams[0], against: veryWeakTeams[1], result:(6,0))>0)

    }
    
    func test_updated_scores(){
        // liveMode should make a difference
        
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
    
//    func testPerformance_get_best_matchsets() throws {
//            self.measure {
//                // Put the code you want to measure the time of here.
//                let goodMatchSetsOnCourt=GoodMatchSetsOnCourt()
//                goodMatchSetsOnCourt.get_best_matchsets(playersOnCourt10, 2)
//                //let finalSets=goodMatchSetsOnCourt.orderedMatchSets
//            
//        }
//    }

}
