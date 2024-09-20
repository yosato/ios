//
//  LiveView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI
import jankenModels

struct LiveSessionView: View {
    var session:GroupSession
    @EnvironmentObject var dataService:DataService
    @StateObject var jankenSeries=JankenSeriesInGroup()
    @EnvironmentObject var authService:AuthService
    @State private var currentChatText:String=""
    //@State var allReadyP=false
    @State var showSeries=false
    @State private var chosenHand="rock"
    var organiser:Member {dataService.registeredMembers.first(where:{member in dataService.ourGroupSession!.organiserUID == member.uid!})!}
    var invitees:Set<Member> {Set(dataService.registeredMembers.filter{member in dataService.ourGroupSession!.inviteeUIDs.contains(member.uid!)})}
    var participatingMembers:Set<Member> {invitees.union(Set([organiser]))}
    var onlineParticipants:Set<Member> {Set(participatingMembers.filter{member in dataService.onlineUserIDs.contains(member.uid ?? "")})}
    var jankenParticipants:Set<Participant> {
        Set(Array(self.participatingMembers).map{member in member.convertIntoParticipant()})
    }
    
    var allReadyP:Bool {participatingMembers==onlineParticipants}
    var sessionState:SessionState {dataService.ourGroupSession == nil || dataService.ourGroupSession!.rounds.isEmpty ? SessionState.NotStarted : SessionState.Completed}
    
    
    var body: some View {
        NavigationStack{
            VStack{
                LogoView().frame(maxHeight:50)
                ParticipantsView(participants:participatingMembers).environmentObject(authService)
                Button("中継"){
                    if(sessionState==SessionState.NotStarted){Task{try await do_and_push_series(jankenParticipants); showSeries=true}}else{
                        Task{let rounds=try await fetch_series();jankenSeries.seriesTree=JankenTree(branches:rounds);showSeries=true}}
                
                    //the first one pushing the button triggers the series
                }.disabled(!allReadyP)
                MessageListView(messages:dataService.messagesInSession)
                //JankenView(chosenHand:$chosenHand).disabled(!allReady)
                HStack{
                    TextField("ここからチャットもできます",text:$currentChatText)
                    Button{
                        dataService.sendMessageToFB(text: currentChatText, session: session) { error in }
                    } label:{Image(systemName:"paperplane.fill")}.disabled(currentChatText.isEmpty)
                }.padding()
            }.navigationDestination(isPresented: $showSeries) {
                SeriesResultView().environmentObject(jankenSeries)
            }
            
        }.onAppear{dataService.listenForUsers()}
    }
    func fetch_series() async throws -> Set<JankenRound> {
        var rounds=Set<JankenRound>()
        //check fetch_seriesTree existence, if not somebody else is still doing janken, so wait a bit
        
        
        return rounds
    }
    func do_and_push_series(_ jParticipants:Set<Participant>) async throws {
        //set the state first
        try await dataService.markSessionState(SessionState.InProgress)
            jankenSeries.add_members(jParticipants)
            jankenSeries.do_jankenSeries_in_group()
            dataService.ourGroupSession!.rounds=Array(jankenSeries.seriesTree.rounds)
            dataService.ourGroupSession!.sessionState=SessionState.Completed
            try await dataService.updateSessionInFB()
    }
    
}

#Preview {
    LiveSessionView(session: GroupSession(sessionName: "tennis",organiserUID:"aaa",inviteeUIDs:Set(["iii","uuu","eee"]), sessionState:SessionState.NotStarted)).environmentObject(DataService()).environmentObject(AuthService())
}
