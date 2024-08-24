//
//  OrganizeView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct OrganizeView: View {
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
    let methods=["お任せ対戦","ライブ対戦"]
    let resultTypes=["全員順位づけ","勝者ひとり"]
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("ようこそ\(authService.userName)さん")
                Spacer()
                Form{
                    Section("対戦相手"){
                        NavigationLink("選ぶ"){
                            PickOpponentsView(selectedOpponents: $selectedOpponents).environmentObject(dataService)
                        }
                        HStack{ForEach(Array(selectedOpponents)){opponent in Text("\(opponent.displayName)")}
                        }

                    }
                    Section("オプション"){
//                        Picker("開催方式",selection:$selectedMethod){
//                            ForEach(methods,id:\.self){
//                                Text($0)
//                            }
//                        }
                        
                        Picker("決定方式",selection:$resultType){
                            ForEach(resultTypes,id:\.self){
                                Text($0)
                            }
                        }
                    }
                    Section("セッション名（任意に変更可）"){
                        TextField(Array(selectedOpponents).map{opponent in opponent.displayName}.sorted().joined(separator: "--"),text:$sessionName)
                    }
                }      //   ZStack{
                Button("開催"){
                    if(sessionName==""){
                        sessionName=selectedOpponents.map{member in member.displayName}.joined(separator:"__")
                    }
//                    dataService.createSessionInFB(session: Session(sessionName:sessionName)){ error in
//                        if let error{
//                            print(error.localizedDescription)
//                        }
//                    }
                    showAlert.toggle()
                }.disabled(selectedOpponents.isEmpty).alert("セッション名は\(sessionName)です。OKを押すと招待メールが送られ全員そろい次第開催されます",isPresented:$showAlert){Button("OK",role:.cancel){
                    gotoLiveView.toggle()
                    invitees+=selectedOpponents
                    sendInvitationEmails(invitees)
                    
                    }
                }
                    .navigationDestination(isPresented: $gotoLiveView){
                    LiveSessionView(session:Session(sessionName:sessionName))
                }
            }.navigationTitle("じゃんけん開催設定").navigationBarTitleDisplayMode(.inline)

        }.onAppear{Task{try? await dataService.fetchMembersFromFB()}}
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
    OrganizeView().environmentObject(AuthService()).environmentObject(DataService())
}
