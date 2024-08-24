//
//  testDelay.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI

struct testDelay: View {
    let firstNumber: Int=1
    let secondNumber: Int=10

    @State var currentNumber = 0
let timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()

var body: some View {
    
    VStack{
//        Rectangle()
//            .frame(width:300, height: 4)
//            .overlay(.pink)
        
        ForEach(firstNumber..<(firstNumber + currentNumber + 1), id: \.self) { number in
     //       let offSetter = -150 + (number-firstNumber) * 30
//            VStack{
//                Rectangle()
//                    .frame(width:4, height: 30, alignment: .leading)
//                    .overlay(.pink)
                Text("\(number)")
//            }
       //     .offset(x:CGFloat(offSetter))
            .transition(.opacity)
        }
    }
    .onReceive(timer) { _ in
        currentNumber += 1
        if currentNumber == secondNumber {
            timer.upstream.connect().cancel()
        }
    }
    .animation(.default, value: currentNumber)
}
}

#Preview {
    testDelay()
}
