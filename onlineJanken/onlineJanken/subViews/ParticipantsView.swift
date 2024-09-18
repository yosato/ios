//
//  ParticipantsView.swift
//  onlineJanken
//
//  Created by Yo Sato on 02/09/2024.
//

import SwiftUI
import jankenModels

struct ParticipantsView: View {
    let participants:Set<Member>
    @EnvironmentObject var dataService:DataService
    //@Binding var allReadyP:Bool
    
    var body: some View {
        VStack{
            List{
            Section("参加者"){
                ForEach(participants.sorted{$0.displayName<$1.displayName}){participant in
                    HStack{
                        if(participant.uid != nil){
                            let userOnlineP=(dataService.onlineUserIDs.contains(participant.uid!))
                            Text(participant.displayName).opacity((userOnlineP ? 1.0 : 0.4))
                            Spacer()
                            Text((userOnlineP ? "online" : "offline")).opacity((userOnlineP ? 1.0 : 0.4))
                        }
                    }
                }
            }//.onChange(of:dataService.onlineUserIDs){
               // allReadyP=(participants.count==dataService.onlineUserIDs.count && Set(dataService.onlineUserIDs)==Set(participants.map{part in part.uid!}))            }
        }
        }
    }
}

#Preview {
    ParticipantsView(participants:
                        Set([
                            Member(displayName: "hahaha", email: "hahaha@hahaha.com")
                            , Member(displayName: "hihihi", email: "hihihi@hihihi.com")
                        ])
                     )
}
