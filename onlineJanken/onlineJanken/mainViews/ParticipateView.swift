//
//  ParticipateView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct ParticipateView: View {
    @EnvironmentObject var authService: AuthService
    let currentUser="Anonymous"
    let inviter="典子"
    let otherInvitees=["陽","元子","Nigel"]
    private var sessionName:String="テニス"
    private var method="ライブ対戦"
    private var resultType="順位づけ"
    private var docID=""
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("ようこそ\(currentUser)さん")
                Spacer()
                Text("\(inviter)さんからじゃんけん対戦に招待されました").font(.subheadline)
                
                Text("セッション名: \(sessionName)").padding()
                Form{
                    Section("他の参加者"){
                        List(otherInvitees,id:\.self){ invitee in
                            Text("\(invitee)")
                        }}
                    Section("対戦方式"){
                        Text("開催方式: \(method)")
                             Text("決定方式: \(resultType)")
                    }
                
            }
                NavigationLink("参加"){LiveSessionView(session:Session(documentID:docID,sessionName:sessionName))}
                
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
    ParticipateView()
}
