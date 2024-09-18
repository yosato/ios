//
//  ResultsView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels

struct RoundResultViewTimer: View {
    let round:JankenRound
    let timer = Timer.publish (every: 1, on: .main, in: .common).autoconnect()
    var lastNumber:Int {round.bouts.count-1}
    //let firstNumber: Int=0
    @State var currentNumber=0
    var numbers:[Int] {Array(0..<(currentNumber+1))}

    var body: some View {
        ScrollViewReader{scrollView in
            //GeometryReader{geo in
            ScrollView{
                if(round.parentAddress==""){Text("初戦")}else{Text(round.parentAddress)}
                LazyVStack{
                    ForEach(numbers,id:\.self){ number in
                        //         VStack{Text("aaa");Text("iii");Text("\(number)")}.padding(10)
                        if(number<=lastNumber){
                            JankenSessionView(session:round.bouts[number])
                        }
                    }.transition(.opacity)

                }.padding().onChange(of:numbers){
                    scrollView.scrollTo(numbers.endIndex-1,anchor:.bottom)
                }
            }
        }
        .onReceive(timer) { time in
            currentNumber += 1
            if currentNumber == lastNumber {
                timer.upstream.connect().cancel()
            }
            //somehow animation chops the last image off at the bottom
            //}//.animation(.default,value:currentNumber)
        }
    }
}
//#Preview {
//    RoundResultViewTimer(round:
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
//                                        Set([
//                                            Participant(displayName: "A", email: "aaa@ccc.co.uk"),
//                                            Participant(displayName: "B", email: "bbb@ccc.co.uk"),
//                                                Participant(displayName: "C", email: "ccc@ccc.co.uk"),
//                                            Participant(displayName: "D", email: "ddd@ccc.co.uk"),
//                                            Participant(displayName: "F", email: "fff@ccc.co.uk"),
//                                            Participant(displayName: "E", email: "eee@ccc.co.uk")
//                                            ,  Participant(displayName: "G", email: "ggg@ccc.co.uk")
//                                            ,  Participant(displayName: "HHHHHHHHH", email: "hhh@ccc.co.uk")
//                                            ,  Participant(displayName: "I", email: "iii@ccc.co.uk")
//                                            
//                                            
//                                        ])),
//                            parentAddress: "",
//                            parentRange: (1...9)
//                                )
//        )
//}
