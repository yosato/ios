//
//  MessageListView.swift
//  onlineJanken
//
//  Created by Yo Sato on 18/08/2024.
//

import SwiftUI
import FirebaseAuth

struct MessageListView: View {
    let messages:[ChatMessage]
    private func isFromCurrentUser(_ chatMessage:ChatMessage)->Bool{
        guard let currentUserInAuth=Auth.auth().currentUser else{return false}
        return currentUserInAuth.uid==chatMessage.uid
    }
    var body: some View {
        ScrollView {
            ForEach(messages){msg in
                VStack{
                    if(isFromCurrentUser(msg)){
                        HStack{
                            Spacer()
                            ChatBubble(chatMessage:msg,direction:.right,colour:.blue)
                        }
                    }else{
                        HStack{
                            ChatBubble(chatMessage: msg, direction: .left, colour: .gray)
                            Spacer()
                        }
                        
                    }
                    Spacer().id(msg.id)
                }.listRowSeparator(.hidden)
                    
            }
        }
    }
    
}
#Preview {
    MessageListView(messages: [])
}
