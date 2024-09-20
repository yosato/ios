//
//  jankenModel.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation
import Combine

public enum JankenHand: String, Codable, CaseIterable{
    case rock="✊"
    case paper="✋"
    case scissors="✌️"

}

public struct Participant: Codable,Identifiable,Equatable,Hashable{
    
    enum CodingKeys: CodingKey {
        case displayName
        case email
        case delimiter
    }
    
    public static func ==(lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let displayName:String
    public var email:String?=nil
    public let delimiter:String="--"
    public var id:String {displayName+delimiter+(email ?? "noEmail")}

//    var records:[JankenRecord]
    
    
    public init(displayName: String, email: String?=nil) {
        self.displayName = displayName
        self.email = email
    }
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}



public struct JankenBout:Codable,Identifiable, Hashable{
    
    public let id:String=UUID().uuidString
    public var participantHandPairs=[Participant:JankenHand]()
    public var participants:Set<Participant> {Set(participantHandPairs.keys)}
    public var handVarieties:Set<JankenHand> {Set(participantHandPairs.values)}
    public var winners:Set<Participant> {self.do_janken_and_get_winners()}
    public var drawnP:Bool {handVarieties.count != 2}
    public var losers:Set<Participant> {(drawnP ? Set() : participants.filter{participant in !winners.contains(participant)})}
    
    let winLossDict=[JankenHand.rock:JankenHand.scissors,
                     JankenHand.paper:JankenHand.rock,
                     JankenHand.scissors:JankenHand.paper]

    public init(_ participantHandPairs:[Participant:JankenHand]){
        self.participantHandPairs=participantHandPairs
        
//        guard participantHandPairs.count<1 else {print("zero or single person cannot do a janken");return}
    }
    func do_janken_and_get_winners()->Set<Participant>{
        if(drawnP){
            return Set()
        }else{
            let twoHands=Array(handVarieties)
            let winningHand=(winLossDict[twoHands[0]]==twoHands[1] ? twoHands[0] : twoHands[1])
            //var winningInds:[Int]=[]
            return Set(participantHandPairs.filter{(participant,hand) in hand==winningHand}.map{(participant,_) in participant})
        }

        
    }
    
}

public func binaryToDecimal(_ binary: String) -> Int {
    var decimal = 0
    var base = 1
     
    if binary==""{
        return -1
    }
    for digit in binary.reversed() {
        if digit == "1" {
            decimal += base
        }
        base *= 2
    }
     
    return decimal
}
 
enum jankenRoundError:Error{
    case ParticipantInconsistency
    case NotDecided
    case NonFinalNotDrawn
}
enum JankenTreeError:Error{
    case RoundNumberError
    case NoRootError
    case AddressError
    case NonContinuousError
    case NonTerminationError
}

public class JankenTree{
    public var rounds=Set<JankenRound>()
    public var sortedLeaves:[Participant] {self.sort_leaves()}
    public var rootRound:JankenRound {rounds.first(where:{round in round.parentAddress==""})!}
    public var participants:Set<Participant> {rootRound.participants}
//    private var addresses:[String] {generate_addresses(participantCount: participants.count)}
    
    public init(branches: Set<JankenRound>) {
        // as many as decided bouts
        if(!branches.isEmpty){
            do{try branches_valid(branches)}catch{print("address error")}}
        self.rounds = branches
        }
    
    func branches_valid(_ rounds:Set<JankenRound>) throws {
        let addressPairs=Dictionary(uniqueKeysWithValues: rounds.map{round in (round.parentAddress,round.childAddresses)})
        let parentAddresses=Array(addressPairs.keys)
        if(!parentAddresses.contains("")){
            throw JankenTreeError.NoRootError
        }
        let parentAddressesExceptRoot=Array(parentAddresses.sorted().dropFirst())
        if(parentAddressesExceptRoot.contains(where:{address in !(CharacterSet(charactersIn: address).contains("0") || CharacterSet(charactersIn: address).contains("1"))})){
            throw JankenTreeError.AddressError
        }
        var prevCount=0
        for i in stride(from:0,to:parentAddressesExceptRoot.count-1,by:2){
            if(parentAddressesExceptRoot[i].count != prevCount+1){
                throw JankenTreeError.AddressError
            }
            prevCount+=1
        }
        
        for (parentAddress,childAddresses) in addressPairs{
            if(Set([childAddresses.0,childAddresses.1]) != Set([parentAddress+"0",parentAddress+"1"])){
                throw JankenTreeError.AddressError
            }
        }
    }
    
//    func is_valid_for_tree(_ branches:Set<JankenRound>) throws {
//        var prevParticipants=Set<Participant>()
//        let finalInd=branches.count-1
//        for (cntr,branch) in branches.enumerated(){
//            if(cntr==0){prevParticipants=branch.participants
//                ;continue}
//            
//            if(branch.participants != prevParticipants){
//                throw jankenTreeError.participantInconsistency
//                }
//            
//        }
//    }
//    
    
    func sort_leaves()->[Participant]{
        var leaves=[(Participant,String)]()
        var winner:Participant?=nil;var loser:Participant?=nil
        for round in self.rounds{
            let winners=round.leftSet
            let losers=round.rightSet
            if ( winners.count==1 || losers.count==1 ){
                if(winners.count==1){
                    winner=winners.first!
                    leaves.append((winner!,round.childAddresses.0))
                }
                if(losers.count==1){
                    loser=losers.first!
                    leaves.append((loser!,round.childAddresses.1))
                }
            }
        }
        return leaves.sorted{$0.1 < $1.1}.map{$0.0}
    }
    
    }

public struct DrawnBouts:Codable,Hashable{
    var participants:Set<Participant>
    var bouts:[JankenBout]=[]
    
    public init(participants:Set<Participant>, bouts: [JankenBout]) {
        self.bouts=bouts
        if(bouts.isEmpty){
            self.participants=participants
        }else{
            assert(self.bouts.map{session in session.drawnP}.reduce(true){$0 && $1})
            self.participants=bouts[0].participants
        }
    }
    public init(participants:Set<Participant>){
        self.participants=participants
        self.bouts=self.generate_drawn_bouts(participants)
    }
    
    func generate_drawn_bouts(_ participants:Set<Participant>)-> [JankenBout]{
        var bouts=[JankenBout]()
        let randomInt=Int.random(in:0..<participants.count*2)
        for _ in (0..<randomInt){
            bouts.append(generate_drawn_bout(participants))
        }
        return bouts
        
    }
    func generate_drawn_bout(_ participants:Set<Participant>)-> JankenBout{
        let jankenHands=[JankenHand.paper,JankenHand.rock,JankenHand.scissors]
        let aJankenHand=jankenHands.randomElement()
        if(participants.count==2){
            return JankenBout(Dictionary(uniqueKeysWithValues:participants.map{participant in (participant,aJankenHand!) }))
        }else{
            let anAttemptedPairs=generate_random_participant_hand_pairs(participants)
            if(Set(anAttemptedPairs.values).count==1){
                return JankenBout(anAttemptedPairs)
            }
            var partHandPairs=[Participant:JankenHand]()
            var intsHands:[Int:JankenHand]=[:]
            var ints=Set(0..<participants.count)
            for hand in jankenHands.shuffled(){
                let anInt=ints.randomElement()!
                ints.remove(anInt)
                intsHands[anInt]=hand
            }
            for (cntr,participant) in participants.enumerated(){
                if(intsHands.keys.contains(cntr)){
                    partHandPairs[participant]=intsHands[cntr]
                }else{
                    partHandPairs[participant]=jankenHands.randomElement()
                }
            }
            return JankenBout(partHandPairs)
        }
    }
    
}

let fakeFinalBoutRoot=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.rock
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.rock
     ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.rock
    ])

let fakeDrawnBoutRoota=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
    ])
let fakeDrawnBoutRootb=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.scissors
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
    ])
let fakeDrawnBoutRootc=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.scissors
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.scissors
     ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.scissors
    ])
let fakeDrawnBoutRootd=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.scissors
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
     ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.scissors
    ])
let fakeDrawnBoutRoote=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.scissors
     ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.rock
    ])
let fakeDrawnBoutRootf=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
     ,Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.rock
     ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
     ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.scissors
    ])
let fakeFinalBout0=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
    ])
let fakeDrawnBout0a=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
    ])

let fakeDrawnBout0b=JankenBout(
    [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
     ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
     ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
     ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
    ])

let fakeFinalBout1=JankenBout(
    [
    Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
    ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.rock
    ])
let fakeDrawnBout1=JankenBout(
    [
    Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.scissors
    ,Participant(displayName:"Aaron", email:"aaron@email.com"): JankenHand.rock
    ])

let fakeFinalBout01=JankenBout(
    [
    Participant(displayName: "John", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Tim", email:"zak@email.com"): JankenHand.rock
    ,Participant(displayName:"Yo", email:"zak@email.com"): JankenHand.paper
 ])
let fakeDrawnBout01=JankenBout(
    [
    Participant(displayName: "John", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Tim", email:"zak@email.com"): JankenHand.rock
    ,Participant(displayName:"Yo", email:"zak@email.com"): JankenHand.scissors
 ])


let fakeFinalBout010=JankenBout(
    [
    Participant(displayName: "John", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Yo", email:"zak@email.com"): JankenHand.scissors
    ])
let fakeDrawnBout010=JankenBout(
    [
    Participant(displayName: "John", email:"mo@email.com"): JankenHand.rock
    ,Participant(displayName:"Tim", email:"zak@email.com"): JankenHand.rock
    ])
let fakeFinalBout10=JankenBout(
    [
    Participant(displayName: "Mo", email:"mo@email.com"): JankenHand.paper
    ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.scissors
    ])


let fakeRoundRoot = JankenRound(finalBout:fakeFinalBoutRoot,
                             drawnBouts:DrawnBouts(participants:fakeFinalBoutRoot.participants,bouts:[fakeDrawnBoutRoota,fakeDrawnBoutRootb,fakeDrawnBoutRootc,fakeDrawnBoutRootd,fakeDrawnBoutRoote,fakeDrawnBoutRootf]),
                             parentAddress:"Root",parentRange:1...7)
let fakeRound0 = JankenRound(finalBout:fakeFinalBout0,
                             drawnBouts:DrawnBouts(participants:fakeFinalBout0.participants, bouts:[fakeDrawnBout0a,fakeDrawnBout0b]),
                             parentAddress:"",parentRange:1...4)
let fakeRound1 = JankenRound(finalBout:fakeFinalBout1,
                             drawnBouts:DrawnBouts(participants:fakeFinalBout1.participants, bouts:[fakeDrawnBout1]),
                             parentAddress:"",parentRange:5...7)
let fakeRound01 = JankenRound(finalBout:fakeFinalBout01,
                             drawnBouts:DrawnBouts(participants:fakeFinalBout01.participants, bouts:[fakeDrawnBout01]),
                             parentAddress:"0",parentRange:2...4)
let fakeRound010 = JankenRound(finalBout:fakeFinalBout010,
                             drawnBouts:DrawnBouts(participants:fakeFinalBout010.participants, bouts:[fakeDrawnBout010]),
                             parentAddress:"00",parentRange:2...3)
let fakeRound10 = JankenRound(finalBout:fakeFinalBout10,
                             drawnBouts:DrawnBouts(participants:fakeFinalBout10.participants, bouts:[]),
                             parentAddress:"1",parentRange:5...6)


let fakeRounds=Set([fakeRoundRoot,fakeRound0,fakeRound1,fakeRound01,fakeRound10,fakeRound010])



public struct JankenRound:Codable,Hashable,Equatable,Identifiable{
    
    public static func ==(lhs: JankenRound, rhs: JankenRound) -> Bool {
            return lhs.bouts == rhs.bouts
        }

    public let finalBout:JankenBout
    public let drawnBouts:DrawnBouts
    public let parentAddress:String
    public let parentRange:ClosedRange<Int>
    public var childAddresses:(String,String) {(parentAddress+"0",parentAddress+"1")}
    
    public let id=UUID().uuidString

    public init(finalBout: JankenBout, drawnBouts: DrawnBouts,  parentAddress: String, parentRange: ClosedRange<Int>) {
        assert(!finalBout.drawnP)
        assert(!finalBout.participants.isEmpty)
        self.finalBout = finalBout
        //guard !finalBout.drawnP else {return}
        assert(drawnBouts.participants==finalBout.participants)
        self.drawnBouts = drawnBouts
        self.parentAddress = parentAddress
        self.parentRange = parentRange
    }

    public var leftSet:Set<Participant> {finalBout.winners}
    public var rightSet:Set<Participant> {finalBout.losers}
    public var participants:Set<Participant> {leftSet.union(rightSet)}

    public var bouts:[JankenBout] {drawnBouts.bouts+[finalBout]}
    public var hasAWinner:Bool {leftSet.count==1}
    public var hasALoser:Bool {rightSet.count==1}
    
}
func divide_set_in_two<T:Hashable>(_ aSet:Set<T>)->(Set<T>,Set<T>){
    let randInt=Int.random(in: 1..<aSet.count)
    var set1=Set<T>()
    for _ in (0..<randInt){
        set1.insert(aSet.randomElement()!)
    }
    let set2:Set<T> = aSet.filter{!set1.contains($0)}
    return (set1,set2)
    
}

func generate_random_participant_hand_pairs(_ sessionParticipants:Set<Participant>)->[Participant:JankenHand]{
    var participantsHands=[Participant:JankenHand]()
    for participant in sessionParticipants{
        participantsHands[participant]=JankenHand.allCases.randomElement()
    }
    return participantsHands
}


enum DrawPattern{
    case AllScissors,AllRock,AllPaper,AllVarieties
}

func generate_samehand_participant_hand_pairs(_ sessionParticipants:Set<Participant>, hand:JankenHand)->[Participant:JankenHand]{
    var participantsHands=[Participant:JankenHand]()
    for participant in sessionParticipants{
        participantsHands[participant]=hand
    }
    return participantsHands
}

//func generate_allvariety_participant_hand_pairs(_ boutParticipants:Set<Participant>)->[Participant:JankenHand]{
//    assert(boutParticipants.count>=3)
//    var participantsHands=[Participant:JankenHand]()
//    for participant in sessionParticipants{
//        participantsHands[participant]=hand
//    }
//    return participantsHands
//}

public enum SessionState:String,Codable{
    case NotStarted="notStarted",InProgress="inProgress",Completed="completed",Outdated="outdated"
}


public class JankenSeriesInGroup:ObservableObject{
    public var groupMembers:Set<Participant>=Set()
    //public var rounds=Set<JankenRound>()
    @Published public var seriesTree=JankenTree(branches:Set())
    public var sessionState:SessionState
    
    
    public init(groupMembers: Set<Participant>=Set()) {
        self.groupMembers = groupMembers
        self.sessionState=SessionState.NotStarted
        //self.seriesTree = seriesTree
//        self.do_jankenSeries_in_group()
    }
    public init(seriesTree: JankenTree) {
        self.groupMembers = seriesTree.participants
        self.seriesTree = seriesTree
        self.sessionState=SessionState.Completed
//        self.do_jankenSeries_in_group()
    }

    public func add_members(_ members:Set<Participant>){
        self.groupMembers=self.groupMembers.union(members)
    }
    
    public func provide_fixed_fakeseries(){
        self.seriesTree=JankenTree(branches:fakeRounds)
        self.groupMembers=seriesTree.participants
    }
    
    
    public func do_jankenSeries_in_group(saishowaGu:Bool=true){
        assert(!self.groupMembers.isEmpty)
        let (rounds,_)=self.develop_jankenbranches(self.groupMembers,cumBranches:Set(),parentAddress:"",parentRange:(1...self.groupMembers.count),bouts:[],saishowaGu:saishowaGu)
        //there always are membersCount-1 rounds
        assert(rounds.count==groupMembers.count-1)
        self.seriesTree=JankenTree(branches:rounds)
    }
    
    func develop_jankenbranches(_ participants:Set<Participant>, cumBranches:Set<JankenRound>, parentAddress:String, parentRange:ClosedRange<Int>, bouts:[JankenBout],saishowaGu:Bool)->(Set<JankenRound>,[JankenBout]){
        var rounds=cumBranches; var bouts=bouts
        var winners:Set<Participant>
        var drawnbouts:[JankenBout]=(saishowaGu ? [JankenBout(generate_samehand_participant_hand_pairs(participants, hand: JankenHand.rock))] : [])
        var drawnP:Bool
        if(participants.count==1){
            return (rounds,bouts)
        }
        var jankenSession:JankenBout
        repeat{
            jankenSession=JankenBout(generate_random_participant_hand_pairs(participants))
            winners=jankenSession.do_janken_and_get_winners()
            if(winners.isEmpty){
                drawnbouts.append(jankenSession)
                bouts.append(jankenSession)
                drawnP=true
            }else{drawnP=false;bouts.append(jankenSession)}
        }while(drawnP)
        let losers=participants.filter{el in !winners.contains(el)}
        rounds.insert(JankenRound(finalBout:jankenSession, drawnBouts:DrawnBouts(participants:participants,bouts:drawnbouts), parentAddress: parentAddress, parentRange:parentRange))
        let leftAddress=parentAddress+"0"; let rightAddress=parentAddress+"1"
        let rangeFirst=parentRange.first!; let rangeLast=parentRange.last!
        let winnerOffset=rangeFirst+winners.count-1; let loserOffset=winnerOffset+1
        let winnerRange=(rangeFirst...winnerOffset)
        let loserRange=(loserOffset...rangeLast)
        assert(winners.count==(winnerOffset-winnerRange.first!+1))
        assert(losers.count==(loserRange.last!-loserOffset+1))
        let (leftRounds,leftbouts)=develop_jankenbranches(winners, cumBranches:rounds, parentAddress:leftAddress, parentRange:winnerRange, bouts:bouts, saishowaGu:saishowaGu)
        let (finalCumRounds,finalbouts)=develop_jankenbranches(losers, cumBranches:leftRounds, parentAddress:rightAddress, parentRange:loserRange, bouts:leftbouts, saishowaGu:saishowaGu)
        return (finalCumRounds,finalbouts)
    }
}

let fakeRoundsSmall=Set([
   JankenRound(finalBout:JankenBout(
       [Participant(displayName:"John",email:"john@email.com"): JankenHand.scissors
    ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
    ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.scissors
    ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
    ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
   ]),
           drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),
                                                           Participant(displayName:"Tim", email:"tim@email.com")
                                                           ,Participant(displayName: "Dan", email:"dan@email.com")
                                                    ,Participant(displayName:"Yo", email:"yo@email.com")
                                                    ,Participant(displayName:"Zak", email:"zak@email.com")
                                                          ]),
                                 bouts:[JankenBout(
                                                           [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                            ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                                            ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
                                                            ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
                                                            ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
                                   ])]),
           parentAddress:"",parentRange:1...5
          )
           
           ,
           JankenRound(finalBout:JankenBout(
   [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
    ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
    ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper
   ]),
           drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),Participant(displayName:"Tim", email:"tim@email.com"),Participant(displayName: "Dan", email:"dan@email.com")]),
               bouts:[
                   JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                               ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
                               ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
                   , JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                 ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                 ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock])
               ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.scissors
                            ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                            ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.scissors])
               ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                            ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
                            ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
               ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.rock,
                        Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors,
                        Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])

           ]),
           parentAddress:"0",parentRange:1...3
          )
           
           ,
           JankenRound(finalBout:JankenBout(
                                   [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                    ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
                                   ]),
                                           drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),Participant(displayName: "Dan", email:"dan@email.com")]),bouts:[
                                               JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.rock,
                                                           Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock])
                                               ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,
                                                           Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
                                               ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,
                                                           Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])

                                           ]
                                           ),
                                           parentAddress:"01",parentRange:2...3
                                          )
           ,
           
           JankenRound(finalBout:JankenBout(
                                   [Participant(displayName:"Yo",email:"yo@email.com"): JankenHand.paper
                                    ,Participant(displayName: "Zak", email:"zak@email.com"): JankenHand.rock
   ]),
           drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"Yo",email:"yo@email.com"),Participant(displayName: "Zak", email:"zak@email.com")]),bouts:[
           ]
           ),
           parentAddress:"1",parentRange:4...5
          )
           
])
   
