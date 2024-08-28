//
//  jankenModel.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation

public enum JankenHand: String, CaseIterable{
    case rock="✊"
    case paper="✋"
    case scissors="✌️"

}

//public class JankenSessions:ObservableObject{
//    @Published public var sessions=[JankenSession]()
//    func add_session(_ jankenSession:JankenSession){
//        self.sessions.append(jankenSession)
//    }
//    public func add_sessions(_ jankenSessions:[JankenSession]){
//        self.sessions+=jankenSessions
//    }
//    func get_stats()->JankenStats{
//        JankenStats(jankenSessions:self.sessions)
//    }
//    
//    public init(sessions: [JankenSession] = [JankenSession]()) {
//        self.sessions = sessions
//    }
//}
//
//struct JankenStats{
//    let jankenSessions:[JankenSession]
//}


public struct Participant: Identifiable,Equatable,Hashable{
    
    public static func ==(lhs: Participant, rhs: Participant) -> Bool {
            return lhs.id == rhs.id
        }

    public let displayName:String
    public let email:String
    public let delimiter:String="--"
    
//    var records:[JankenRecord]
    
    public var id:String{
        displayName+delimiter+email
    }
    
    public init(displayName: String, email: String) {
        self.displayName = displayName
        self.email = email
    }
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}



public struct JankenSession:Identifiable, Hashable{
    
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
 


public class JankenTree{
    public var rounds=Set<JankenRound>()
    public var sortedLeaves:[Participant] {self.sort_leaves()}
    
    public init(branches: Set<JankenRound>) {
        // as many as decided sessions
        self.rounds = branches
        // both decided and drawn sessions
//        self.drawnSessionInds=sessions.enumerated().filter{(cntr,session) in session.drawnP}.map{(cntr,_) in cntr}
//        
//        var drawnSessionIDs=Set<String>(); var decidedSessionIDs=Set<String>()
//        for (cntr,session) in sessions.enumerated(){
//            if drawnSessionInds.contains(cntr){
//                drawnSessionIDs.insert(session.id)
//            }else{decidedSessionIDs.insert(session.id)}
//        }
//        var idsInDecidedSessionsInBranches=Set<String>(); var idsInDrawnSessionsInBranches=Set<String>();
//        for branch in branches{
//            idsInDecidedSessionsInBranches.insert(branch.finalSessionID)
//            for drawnID in branch.drawSessionIDs{
//                idsInDrawnSessionsInBranches.insert(drawnID)
//            }
//        }
//        self.drawnSessionIDs=drawnSessionIDs
//        assert(idsInDrawnSessionsInBranches==drawnSessionIDs)
//        assert(idsInDecidedSessionsInBranches==decidedSessionIDs)
        }
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

public struct DrawnSessions:Hashable{
    var participants:Set<Participant>
    var sessions:[JankenSession]=[]
    
    public init(participants:Set<Participant>, sessions: [JankenSession]) {
        self.sessions=sessions
        if(sessions.isEmpty){
            self.participants=participants
        }else{
            assert(self.sessions.map{session in session.drawnP}.reduce(true){$0 && $1})
            self.participants=sessions[0].participants
        }
    }
    public init(participants:Set<Participant>){
        self.participants=participants
        self.sessions=self.generate_drawn_sessions(participants)
    }
    
    func generate_drawn_sessions(_ participants:Set<Participant>)-> [JankenSession]{
        var sessions=[JankenSession]()
        let randomInt=Int.random(in:0..<participants.count*2)
        for _ in (0..<randomInt){
            sessions.append(generate_drawn_session(participants))
        }
        return sessions
        
    }
    func generate_drawn_session(_ participants:Set<Participant>)-> JankenSession{
        let jankenHands=[JankenHand.paper,JankenHand.rock,JankenHand.scissors]
        let aJankenHand=jankenHands.randomElement()
        if(participants.count==2){
            return JankenSession(Dictionary(uniqueKeysWithValues:participants.map{participant in (participant,aJankenHand!) }))
        }else{
            let anAttemptedPairs=assign_hand_to_participants(participants)
            if(Set(anAttemptedPairs.values).count==1){
                return JankenSession(anAttemptedPairs)
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
            return JankenSession(partHandPairs)
        }
    }
    
}

public struct JankenRound:Hashable,Equatable{
    
    public static func ==(lhs: JankenRound, rhs: JankenRound) -> Bool {
            return lhs.sessions == rhs.sessions
        }

    public let finalSession:JankenSession
    public let drawnSessions:DrawnSessions
    public let parentAddress:String
    public let parentRange:ClosedRange<Int>
    public var childAddresses:(String,String) {(parentAddress+"0",parentAddress+"1")}

    public init(finalSession: JankenSession, drawnSessions: DrawnSessions,  parentAddress: String, parentRange: ClosedRange<Int>) {
        assert(!finalSession.drawnP)
        assert(!finalSession.participants.isEmpty)
        self.finalSession = finalSession
        //guard !finalSession.drawnP else {return}
        assert(drawnSessions.participants==finalSession.participants)
        self.drawnSessions = drawnSessions
        self.parentAddress = parentAddress
        self.parentRange = parentRange
    }

    public var leftSet:Set<Participant> {finalSession.winners}
    public var rightSet:Set<Participant> {finalSession.losers}

    public var sessions:[JankenSession] {drawnSessions.sessions+[finalSession]}
    public var hasAWinner:Bool {leftSet.count==1}
    public var hasALoser:Bool {rightSet.count==1}
    
}
//
//public struct JankenRound0:Hashable{
//    public let finalSessionID:String
//    public let drawSessionIDs:[String]
//    
//    //public let finalSession:JankenSession
//    //public let drawnSessions:[JankenSession]
//    //public var sessions:[JankenSession] {drawnSessions+[finalSession]}
//    
//    public let leftSet:Set<Participant>
//    public let rightSet:Set<Participant>
//    public var hasAWinner:Bool {leftSet.count==1}
//    public var hasALoser:Bool {rightSet.count==1}
//    public let parentAddress:String
//    public let parentRange:ClosedRange<Int>
//    public var childAddresses:(String,String) {(parentAddress+"0",parentAddress+"1")}
//    
//}

func divide_set_in_two<T:Hashable>(_ aSet:Set<T>)->(Set<T>,Set<T>){
    let randInt=Int.random(in: 1..<aSet.count)
    var set1=Set<T>()
    for _ in (0..<randInt){
        set1.insert(aSet.randomElement()!)
    }
    let set2:Set<T> = aSet.filter{!set1.contains($0)}
    return (set1,set2)
    
}

func assign_hand_to_participants(_ sessionParticipants:Set<Participant>)->[Participant:JankenHand]{
    var participantsHands=[Participant:JankenHand]()
    for participant in sessionParticipants{
        participantsHands[participant]=JankenHand.allCases.randomElement()
    }
    return participantsHands
}

public class JankenSeriesInGroup:ObservableObject{
    public var groupMembers=Set<Participant>()
    public var rounds=Set<JankenRound>()
    
    
    @Published public private(set) var seriesTree=JankenTree(branches:Set())
    
    
    public init(groupMembers: Set<Participant>=Set(), seriesTree: JankenTree = JankenTree(branches:Set())) {
        self.groupMembers = groupMembers
        self.seriesTree = seriesTree
//        self.do_jankenSeries_in_group()
    }
    
    
    public func do_jankenSeries_in_group(){
        let (rounds,_)=self.develop_jankenbranches(self.groupMembers,cumBranches:Set(),parentAddress:"",parentRange:(1...self.groupMembers.count),sessions:[])
        //there always are membersCount-1 rounds
        assert(rounds.count==groupMembers.count-1)
        self.seriesTree=JankenTree(branches:rounds)
    }
    
    func develop_jankenbranches(_ participants:Set<Participant>, cumBranches:Set<JankenRound>, parentAddress:String, parentRange:ClosedRange<Int>, sessions:[JankenSession])->(Set<JankenRound>,[JankenSession]){
        var rounds=cumBranches; var sessions=sessions
        var winners:Set<Participant>
        var drawnSessions:[JankenSession]=[]
        var drawnP:Bool
        if(participants.count==1){
            return (rounds,sessions)
        }
        var jankenSession:JankenSession
        repeat{
            jankenSession=JankenSession(assign_hand_to_participants(participants))
            winners=jankenSession.do_janken_and_get_winners()
            if(winners.isEmpty){
                drawnSessions.append(jankenSession)
                sessions.append(jankenSession)
                drawnP=true
            }else{drawnP=false;sessions.append(jankenSession)}
        }while(drawnP)
        let losers=participants.filter{el in !winners.contains(el)}
        rounds.insert(JankenRound(finalSession:jankenSession, drawnSessions:DrawnSessions(participants:participants,sessions:drawnSessions), parentAddress: parentAddress, parentRange:parentRange))
        let leftAddress=parentAddress+"0"; let rightAddress=parentAddress+"1"
        let rangeFirst=parentRange.first!; let rangeLast=parentRange.last!
        let winnerOffset=rangeFirst+winners.count-1; let loserOffset=winnerOffset+1
        let winnerRange=(rangeFirst...winnerOffset)
        let loserRange=(loserOffset...rangeLast)
        assert(winners.count==(winnerOffset-winnerRange.first!+1))
        assert(losers.count==(loserRange.last!-loserOffset+1))
        let (leftRounds,leftSessions)=develop_jankenbranches(winners, cumBranches:rounds, parentAddress:leftAddress, parentRange:winnerRange, sessions:sessions)
        let (finalCumRounds,finalSessions)=develop_jankenbranches(losers, cumBranches:leftRounds, parentAddress:rightAddress, parentRange:loserRange, sessions:leftSessions)
        return (finalCumRounds,finalSessions)
    }
}

