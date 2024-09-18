//
//  OrganizeView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI



struct OrganizeView: View {
    let organiser:Member
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var dataService: DataService
    //let fakeName="信子"
    @State private var selectedMethod="お任せ対戦"
    @State private var resultType="順位づけ"
    @State private var gotoLiveView=false
    @State private var showAlert=false
    @State private var selectedOpponents=Set<Member>()
    @State private var sessionName:String=""
    @State private var invitees:[Member]=[]
    var opponentNamesString:String {Array(selectedOpponents).map{opponent in opponent.displayName.replacingOccurrences(of: " ", with: "_")}.sorted().joined(separator: "--")}
    var namesString:String {organiser.displayName+":"+opponentNamesString}
    let methods=["お任せ対戦","ライブ対戦"]
    let resultTypes=["順位づけ","勝者ひとり"]
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("主催者 \(organiser.displayName)")
                Spacer()
                Form{
                    Section("対戦相手"){
                        NavigationLink("選ぶ"){
                            PickOpponentsView(organiser:organiser,selectedOpponents: $selectedOpponents).environmentObject(dataService)
                        }
                        HStack{ForEach(Array(selectedOpponents)){opponent in Text("\(opponent.displayName)")}
                        }
                    }
                    Section("オプション"){
                        Picker("決定方式",selection:$resultType){
                            ForEach(resultTypes,id:\.self){
                                Text($0)
                            }
                        }
                    }
                    Section("セッション名（任意に変更可）"){
                        
                        TextField(namesString,text:$sessionName)
                    }
                }      //   ZStack{
                Button("開催"){
                    showAlert.toggle()
                }.disabled(selectedOpponents.isEmpty).alert("セッション名は\(sessionName)です。\nOKを押すと招待メールが送られ全員が了承次第開催されます", isPresented:$showAlert){
                    Button("Cancel",role:.cancel){}
                    Button("OK"){
                        Task{    let inviteeUIDs=Set(selectedOpponents.map{opp in opp.uid!})
                            var groupSession=GroupSession(sessionName: sessionName, organiserUID: organiser.uid!, inviteeUIDs: inviteeUIDs)
                            if let sessionDocRef=try? await dataService.createEmptySessionInFB(session: groupSession){
                                groupSession.id=sessionDocRef.documentID
                                dataService.ourGroupSession=groupSession

                            }
                            //sendInvitationEmails(invitees)
                            gotoLiveView=true }
                    }
                }
                    .navigationDestination(isPresented: $gotoLiveView){
                        LiveSessionView(session:dataService.ourGroupSession!)  }
            }.navigationTitle("じゃんけん開催設定").navigationBarTitleDisplayMode(.inline)

        }.onAppear{sessionName=namesString
                            Task{try? await dataService.fetchMembersFromFB()}}
    }
    func sendEmail(_ email:String,adressee:String="Member"){
        
    }
    func sendInvitationEmails(_ invitees:[Member]){
        for invitee in invitees{
            sendEmail(invitee.email,adressee:invitee.displayName)
        }
    }
}
#Preview {
    OrganizeView(organiser:Member(displayName: "hahaha", email: "hihihi@hihihi.com")).environmentObject(AuthService()).environmentObject(DataService())
}
