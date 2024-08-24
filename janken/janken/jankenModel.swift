//
//  jankenModel.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation

public enum JankenHand: String, CaseIterable{
    case rock="rock"
    case paper="paper"
    case scissors="scissors"

}

public class JankenSessions:ObservableObject{
    @Published public var sessions=[JankenSession]()
    func add_session(_ jankenSession:JankenSession){
        self.sessions.append(jankenSession)
    }
    public func add_sessions(_ jankenSessions:[JankenSession]){
        self.sessions+=jankenSessions
    }
    func get_stats()->JankenStats{
        JankenStats(jankenSessions:self.sessions)
    }
    
    public init(sessions: [JankenSession] = [JankenSession]()) {
        self.sessions = sessions
    }
}

struct JankenStats{
    let jankenSessions:[JankenSession]
}

public struct Participant: Identifiable,Equatable,Hashable{
    
    public static func ==(lhs: Participant, rhs: Participant) -> Bool {
            return lhs.id == rhs.id
        }
    
    public let displayName:String
    public let email:String
    public let delimiter:String="--"
    
//    var records:[JankenRecord]
    
    public private(set) var id:String{
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



public struct JankenSession:Identifiable{
    public let id=UUID()
    public var participantHandPairs=[Participant:JankenHand]()
    public var participants:[Participant] {Array(participantHandPairs.keys)}
    public var winners:[Participant] {self.do_janken_and_get_winners()}
    
    let winLossDict=[JankenHand.rock:JankenHand.scissors,
                     JankenHand.paper:JankenHand.rock,
                     JankenHand.scissors:JankenHand.paper]

    public init(_ participantHandPairs:[Participant:JankenHand]){
        self.participantHandPairs=participantHandPairs
        
//        guard participantHandPairs.count<1 else {print("zero or single person cannot do a janken");return}
    }
    func do_janken_and_get_winners()->[Participant]{
        let handVarieties=Set(participantHandPairs.values)
        if(handVarieties.count != 2){
            return []
        }else{
            let twoHands=Array(handVarieties)
            let winningHand=(winLossDict[twoHands[0]]==twoHands[1] ? twoHands[0] : twoHands[1])
            //var winningInds:[Int]=[]
            return participantHandPairs.filter{(participant,hand) in hand==winningHand}.map{(participant,_) in participant}
        }

        
    }
    
}

struct JankenInGroup{
    let groupMembers:[Participant]
    func assign_hand_to_participants(_ sessionParticipants:[Participant])->[Participant:JankenHand]{
        var participantsHands=[Participant:JankenHand]()
        for participant in sessionParticipants{
            participantsHands[participant]=JankenHand.allCases.randomElement()
        }
        return participantsHands
    }
    func do_session_and_get_winner_loser_split(_ participants:[Participant])->(([Participant],[Participant]),[JankenSession]){
        var winners:[Participant]
        var sessionRecord:[JankenSession]=[]
        repeat{
            let session=JankenSession(assign_hand_to_participants(participants))
            sessionRecord.append(session)
            winners=session.do_janken_and_get_winners()
        }while(winners.isEmpty)
        let losers=participants.filter{participant in !winners.contains(participant)}
        return ((winners,losers),sessionRecord)
    }
    func do_jankenseries_and_get_order()->[Participant:Int]{
        var results=[Participant:Int]()
        var determinedCounts=[0,0]
        let splitAndRecord=do_session_and_get_winner_loser_split(groupMembers)
        var previousWinnersLosersPair:([Participant],[Participant])=splitAndRecord.0
        while(results.count != groupMembers.count){
            for (cntr,split) in [previousWinnersLosersPair.0,previousWinnersLosersPair.1].enumerated(){
                if(split.count==1){
                    let orderNum=(cntr==0 ? determinedCounts[cntr]+1 : groupMembers.count-determinedCounts[cntr])
                    results[split[0]]=orderNum
                    determinedCounts[cntr]+=1
                }
                (previousWinnersLosersPair, _)=do_session_and_get_winner_loser_split(split)
            }
        }
        return results
    }
}

