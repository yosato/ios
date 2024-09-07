//
//  ParticipateView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct ParticipateView: View {
    @EnvironmentObject var authService: AuthService
    let groupSession:GroupSession
    let currentUser="Anonymous"
    var sessionName:String="テニス"
    var method="ライブ対戦"
    var resultType="順位づけ"
    var docID=""
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("ようこそ\(currentUser)さん")
                Spacer()
                Text("\(groupSession.organiser)さんからじゃんけん対戦に招待されました").font(.subheadline)
                
                Text("セッション名: \(sessionName)").padding()
                Form{
                    Section("他の参加者"){
                        List(groupSession.invitees.map{invitee in invitee.displayName},id:\.self){ invitee in
                            Text("\(invitee)")
                        }}
                    Section("対戦方式"){
                        Text("開催方式: \(method)")
                             Text("決定方式: \(resultType)")
                    }
                
            }
                NavigationLink("参加"){LiveSessionView(session:groupSession)}
                
            }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out") {
                            print("Log out tapped!")
                            authService.regularSignOut { error in
                                
                                if let e = error {
                                    print(e.localizedDescription)
                                }
                            }
                        }
                    }
                }.navigationTitle("じゃんけん対戦招待").navigationBarTitleDisplayMode(.inline)
        }
    }

}

#Preview {
    ParticipateView(groupSession: GroupSession(documentID: "mock", sessionName: "tennis", organiser: Member(displayName:"hahaha",email:"hahaha@hahaha.com"), invitees: Set([])))
}
