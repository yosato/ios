//
//  LiveView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct LiveSessionView: View {
    let session:Session
    @EnvironmentObject private var dataService:DataService
    @State private var currentChatText:String=""
    var allReady=false
    @State private var chosenHand="rock"
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                MessageListView(messages:dataService.messagesInSession)
                JankenView(chosenHand:$chosenHand).disabled(!allReady)
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
    LiveSessionView(session: Session(documentID: "123", sessionName: "tennis")).environmentObject(DataService())
}
