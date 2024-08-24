//
//  JankenView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI
import PhotosUI

struct JankenView: View {
    @Binding var chosenHand:String
    let hands=["rock","scissors","paper"]
    var body: some View {
        VStack{
            Picker("",selection:$chosenHand){ForEach(hands,id:\.self){hand in Image(hand)}}.frame(height:100).pickerStyle(.segmented).scaledToFit().scaleEffect(CGSize(width:1.0,height:2)).padding(.horizontal,40)
        }
    }
}

#Preview {
    JankenView(chosenHand: .constant("rock"))
}
