//
//  ChatBubble.swift
//  onlineJanken
//
//  Created by Yo Sato on 18/08/2024.
//

import SwiftUI
enum BubbleDirection{
    case left
    case right
}

struct ChatBubble: View {
    let chatMessage:ChatMessage
    let direction:BubbleDirection
    let colour:Color
    
//    @ViewBuilder
//    private func put_profilePhoto_bubble(chatMessage:ChatMessage)->some View{
//        if let profilePhotoURL=chatMessage.profilePhotoURL{
//            AsyncImage(url:profilePhotoURL){image in
//                image.rounded(width:34,height:34)
//            } placeholder: {
//                Image(systemName: "person.crop.circle").font(.title)
//            }
//        }
//    }
    
    var body: some View {
        HStack{
            VStack(alignment:.leading,spacing:5){
                Text(chatMessage.displayName).opacity(0.8).font(.caption).foregroundColor(.white)
                Text(chatMessage.text)
                Text(chatMessage.dateCreated,format:.dateTime).font(.caption).opacity(0.5).frame(maxWidth:200,alignment:.trailing)
            }.padding(8).background(colour).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius:10.0,style:.continuous))
            
        }   .overlay(alignment:direction==BubbleDirection.left ? .bottomLeading : .bottomTrailing){Image(systemName:"arrowtriangle.down.fill")
                .rotationEffect(.degrees(direction == .left ? 45 : -45))
                .offset(x: direction == .left ? 30 : -30, y: 10)
                .foregroundColor(colour)
            
        }

    }
}

#Preview {
    ChatBubble(chatMessage:ChatMessage(documentID: "ABVC", text: "helloo", uid: "abcd", displayName: "Johny Rotten", dateCreated: Date(),profilePhotoURLString: ""),direction:BubbleDirection.right,colour:.blue)
    
}
