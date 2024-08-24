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
 


public class JankenTree:ObservableObject{
    public var rounds=Set<JankenRound>()
    var sessions=[JankenSession]()
    public var IDsSessions:[String:JankenSession] {
        var idsSessions:[String:JankenSession]=[:]
            for session in self.sessions{
                idsSessions[session.id]=session
            }
            return idsSessions
        }
    
    var drawnSessionInds:[Int]
    var drawnSessionIDs:Set<String>
    public var sortedLeaves:[Participant] {self.sort_leaves()}
    
    public init(branches: Set<JankenRound>, sessions:[JankenSession]) {
        // as many as decided sessions
        self.rounds = branches
        // both decided and drawn sessions
        self.sessions=sessions
        self.drawnSessionInds=sessions.enumerated().filter{(cntr,session) in session.drawnP}.map{(cntr,_) in cntr}
        
        var drawnSessionIDs=Set<String>(); var decidedSessionIDs=Set<String>()
        for (cntr,session) in sessions.enumerated(){
            if drawnSessionInds.contains(cntr){
                drawnSessionIDs.insert(session.id)
            }else{decidedSessionIDs.insert(session.id)}
        }
        var idsInDecidedSessionsInBranches=Set<String>(); var idsInDrawnSessionsInBranches=Set<String>();
        for branch in branches{
            idsInDecidedSessionsInBranches.insert(branch.finalSessionID)
            for drawnID in branch.drawSessionIDs{
                idsInDrawnSessionsInBranches.insert(drawnID)
            }
        }
        self.drawnSessionIDs=drawnSessionIDs
        assert(idsInDrawnSessionsInBranches==drawnSessionIDs)
        assert(idsInDecidedSessionsInBranches==decidedSessionIDs)
        }
    func sort_leaves()->[Participant]{
        var leaves=[(Participant,Int)]()
        var winner:Participant?=nil;var loser:Participant?=nil
        for round in self.rounds{
            let winners=round.leftSet
            let losers=round.rightSet
            if ( winners.count==1 || losers.count==1 ){
                if(winners.count==1){
                    winner=winners.first!
                    leaves.append((winner!,binaryToDecimal(round.childAddresses.0)))
                }
                if(losers.count==1){
                    loser=losers.first!
                    leaves.append((loser!,binaryToDecimal(round.childAddresses.1)))
                }
            }
        }
        return leaves.sorted{$0.1 < $1.1}.map{$0.0}
    }
    
    }

public struct JankenRound:Hashable{
    public let finalSessionID:String
    public let leftSet:Set<Participant>
    public let rightSet:Set<Participant>
    public let parentAddress:String
    public let drawSessionIDs:[String]
    var childAddresses:(String,String) {(parentAddress+"0",parentAddress+"1")}
    
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

public class JankenSeriesInGroup:ObservableObject{
    public var groupMembers:Set<Participant>
    @Published public private(set) var seriesTree=JankenTree(branches:Set(),sessions:[])
    
    
    public init(groupMembers: Set<Participant>=Set(), seriesTree: JankenTree = JankenTree(branches:Set(),sessions:[])) {
        self.groupMembers = groupMembers
        self.seriesTree = seriesTree
        self.do_jankenSeries_in_group()
    }
    
    func assign_hand_to_participants(_ sessionParticipants:Set<Participant>)->[Participant:JankenHand]{
        var participantsHands=[Participant:JankenHand]()
        for participant in sessionParticipants{
            participantsHands[participant]=JankenHand.allCases.randomElement()
        }
        return participantsHands
    }
    
    func do_jankenSeries_in_group(){
        let (branches,sessions)=self.develop_jankenbranches(self.groupMembers)
        let branchCount=branches.count
        assert(branchCount==groupMembers.count-1)
        let drawnCount=branches.map{br in br.drawSessionIDs.count}.reduce(0,+)
        assert(sessions.count==branchCount+drawnCount)
        self.seriesTree=JankenTree(branches:branches,sessions:sessions)
    }
    
    func develop_jankenbranches(_ participants:Set<Participant>, cumBranches:Set<JankenRound>=Set(), parentAddress:String="", sessions:[JankenSession]=[])->(Set<JankenRound>,[JankenSession]){
        var cumBranches=cumBranches; var sessions=sessions
        var winners:Set<Participant>
        var drawSessionIDs:[String]=[]
        var drawnP:Bool
        if(participants.count==1){
            return (cumBranches,sessions)
        }
        var jankenSession:JankenSession
        repeat{
            jankenSession=JankenSession(self.assign_hand_to_participants(participants))
            winners=jankenSession.do_janken_and_get_winners()
            if(winners.isEmpty){
                drawSessionIDs.append(jankenSession.id)
                sessions.append(jankenSession)
                drawnP=true
            }else{drawnP=false;sessions.append(jankenSession)}
        }while(drawnP)
        let losers=participants.filter{el in !winners.contains(el)}
        cumBranches.insert(JankenRound(finalSessionID:jankenSession.id, leftSet: winners, rightSet: losers, parentAddress: parentAddress, drawSessionIDs:drawSessionIDs))
        let leftAddress=parentAddress+"0"; let rightAddress=parentAddress+"1"
        let (leftBranches,leftSessions)=develop_jankenbranches(winners, cumBranches:cumBranches, parentAddress:leftAddress, sessions:sessions)
        let (finalCumBranches,finalSessions)=develop_jankenbranches(losers, cumBranches:leftBranches, parentAddress:rightAddress, sessions:leftSessions)
        return (finalCumBranches,finalSessions)
    }
}

