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
    
    var body: some View {
        List{
            ForEach(participants.sorted{$0.displayName<$1.displayName}){participant in
                Text(participant.displayName).opacity(participant.onlineP ? 1.0 : 0.4)
                
            }
        }
    }
}

#Preview {
    ParticipantsView(participants:
            Set([
                            Member(displayName: "hahaha", email: "hahaha@hahaha.com")
                            , Member(displayName: "hihihi", email: "hihihi@hihihi.com", onlineP:true)
                        ]))
}
