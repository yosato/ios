//
//  ResultsView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels

struct RoundResultView: View {
    let round:JankenRound
    //    let timer = Timer.publish (every: 1, on: .main, in: .common).autoconnect()
    //    var lastNumberInner:Int {round.sessions.count-1}
    @State var currentNumberInner=0
    var numbersInner:[Int] {Array(0...currentNumberInner)}
    //@State var scrollToIndex:Int=0
    var sessionCount:Int {round.bouts.count}
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollViewReader{scrollView in
            ScrollView{
                VStack{
                    if(round.parentAddress==""){Text("初戦")}else{Text(round.parentAddress)}
                    VStack{
                        ForEach(numbersInner,id:\.self){ numberInner in
                            if(numberInner<sessionCount){
                                JankenSessionView(session:round.bouts[numberInner]).padding().onAppear{
                                    //scrollToIndex+=1
                                    DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+1){currentNumberInner+=1}}
                            }
                        }.transition(.opacity)        .onChange(of:currentNumberInner){
                            scrollView.scrollTo(currentNumberInner, anchor:.center)
                        }
                    }
                }
            }
        }
    }
}
//#Preview {
//    RoundResultView(round:
//                        JankenRound(
//                            finalSession: JankenBout([
//                                Participant(displayName: "A", email: "aaa@ccc.co.uk"): JankenHand.rock
//                                , Participant(displayName: "B", email: "bbb@ccc.co.uk"): JankenHand.rock
//                                , Participant(displayName: "C", email: "ccc@ccc.co.uk"): JankenHand.rock
//                                ,   Participant(displayName: "D", email: "ddd@ccc.co.uk"): JankenHand.scissors
//                                ,   Participant(displayName: "F", email: "fff@ccc.co.uk"): JankenHand.scissors
//                                ,  Participant(displayName: "E", email: "eee@ccc.co.uk"): JankenHand.rock
//                                ,  Participant(displayName: "G", email: "ggg@ccc.co.uk"): JankenHand.rock
//                                ,  Participant(displayName: "HHHHHHHHH", email: "hhh@ccc.co.uk"): JankenHand.rock
//                                ,  Participant(displayName: "I", email: "iii@ccc.co.uk"): JankenHand.rock
//                            ]),
//                            drawnSessions: DrawnBouts(participants:
//                                                            Set([
//                                                                Participant(displayName: "A", email: "aaa@ccc.co.uk"),
//                                                                Participant(displayName: "B", email: "bbb@ccc.co.uk"),
//                                                                Participant(displayName: "C", email: "ccc@ccc.co.uk"),
//                                                                Participant(displayName: "D", email: "ddd@ccc.co.uk"),
//                                                                Participant(displayName: "F", email: "fff@ccc.co.uk"),
//                                                                Participant(displayName: "E", email: "eee@ccc.co.uk")
//                                                                ,  Participant(displayName: "G", email: "ggg@ccc.co.uk")
//                                                                ,  Participant(displayName: "HHHHHHHHH", email: "hhh@ccc.co.uk")
//                                                                ,  Participant(displayName: "I", email: "iii@ccc.co.uk")
//                                                                
//                                                                
//                                                            ])),
//                            parentAddress: "",
//                            parentRange: (1...9)
//                        )
//    )
//}
