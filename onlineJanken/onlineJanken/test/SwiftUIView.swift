//
//  SwiftUIView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI

struct SwiftUIView: View {
    let myArray=[1,2,3,4,5,6]
    @State var currentInd=0
    var body: some View {
        if(currentInd<=5){
            Text("\(myArray[currentInd])").onAppear{DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+1){currentInd+=1}}.onChange(of:currentInd){DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+1){currentInd+=1}}
        }
    }
}

#Preview {
    SwiftUIView()
}
