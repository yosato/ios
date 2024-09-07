//
//  LiveView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct LiveSessionView: View {
    var session:GroupSession
    @EnvironmentObject private var dataService:DataService
    @EnvironmentObject private var authService:AuthService
    @State private var currentChatText:String=""
    var allReady=false
    @State private var chosenHand="rock"
    @State private var participants:Set<Member>=Set()
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                
                ParticipantsView(participants:session.members)
                MessageListView(messages:dataService.messagesInSession)
                //JankenView(chosenHand:$chosenHand).disabled(!allReady)
                HStack{
                    TextField("ここからチャットもできます",text:$currentChatText)
                    Button{
                        dataService.sendMessageToFB(text: currentChatText, session: session) { error in }
                    } label:{Image(systemName:"paperplane.fill")}.disabled(currentChatText.isEmpty)
                }.padding()
            }
        }.onAppear{dataService.listenForMessagesInSession(in: session)}
    }
}

#Preview {
    LiveSessionView(session: GroupSession(documentID: "123", sessionName: "tennis",organiser:Member(displayName:"aaa",email:"aaa@aaa.com"),invitees:Set([Member(displayName: "hahaha", email: "hahaha@hahaha.com")]))).environmentObject(DataService())
}
