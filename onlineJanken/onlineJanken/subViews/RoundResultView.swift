//
//  ResultsView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels

struct RoundResultView: View {
    let sessions:[JankenSession]
    let timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
    var lastNumber:Int {sessions.count-1}
    let firstNumber: Int=0
    @State var currentNumber=0
    var numbers:[Int] {Array(firstNumber..<(firstNumber+currentNumber+1))}
    
    var body: some View {
        ScrollViewReader{scrollView in
            //GeometryReader{geo in
                ScrollView{
                    LazyVStack{
                        ForEach(numbers,id:\.self){ number in
                   //         VStack{Text("aaa");Text("iii");Text("\(number)")}.padding(10)
                            JankenSessionView(session:sessions[number])
                            
                        }.transition(.opacity)
                        
                    }.onChange(of:numbers){
                        scrollView.scrollTo(numbers.endIndex-1,anchor:.bottom)
                    }
                }}
            .onReceive(timer) { _ in
                currentNumber += 1
                if currentNumber == lastNumber {
                    timer.upstream.connect().cancel()
                }
            //}//.animation(.default,value:currentNumber)
        }
    }
}
#Preview {
    RoundResultView(sessions:   [
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.rock,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.rock,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.paper,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.rock,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.rock,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.paper,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.rock,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.rock,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.paper,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.paper,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.rock,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.rock,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.paper,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock])
    ]
)
}
