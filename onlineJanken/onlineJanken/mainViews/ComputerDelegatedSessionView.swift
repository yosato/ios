//
//  ComputerDelegatedSessionView.swift
//  onlineJanken
//
//  Created by Yo Sato on 15/08/2024.
//

import SwiftUI

enum SessionState{
    case standBy
    case allReady
    case inProgress
    case completed
}

struct ComputerDelegatedSessionView: View {
    let organiser:Member=Member(displayName: "aaa", email: "iii@uuu")
    let selectedOpponents:[Member]=[Member(displayName: "kkk", email: "iii@uuu")]
    @State private var sessionState:SessionState=SessionState.standBy
    var remainingMins:Int=5
    var body: some View {
        NavigationStack{
            VStack{
//                Form{
                VStack{List{
                    Text("主催者:  \(organiser.displayName)")
                    HStack{Text("他の参加者: ");ForEach(selectedOpponents){ Text($0.displayName) }}
                }//.listStyle(.plain)
                    //                }
                    //              }
//                    var textToDisplay:String
                    switch sessionState{
                    case .standBy:Text("待機中：参加者がそろい次第開催されます")
                    case .allReady:Text("手続完了：あと\(remainingMins)分で開催されます")
                    case .inProgress:Text("開催中")
                    case .completed:Text("結果が出ました")
                    }
                    
                }.frame(height:200)
                
                ScrollView{
                    
                }
        
            }.navigationTitle("お任せ対戦").navigationBarTitleDisplayMode(.inline)
             
            }
            }
        }
    


#Preview {
    ComputerDelegatedSessionView()
}
