//
//  JankenView.swift
//  janken
//
//  Created by Yo Sato on 15/08/2024.
//

import SwiftUI

struct JankenView: View {
    @EnvironmentObject var jankenSessions:JankenSessions
    var fakeSessions=[JankenSession(participantHandPairs: [Participant(displayName: "aaa", email: "bbb@ccc"): JankenHand.rock])]
    var body: some View {
        ScrollView{
            List(jankenSessions.sessions){session in
                Text(session.id.uuidString)
                
            }
        }.onAppear{jankenSessions.add_sessions(fakeSessions)}
    }
}

#Preview {
    JankenView().environmentObject(JankenSessions())
}
