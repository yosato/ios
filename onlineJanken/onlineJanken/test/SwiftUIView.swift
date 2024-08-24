//
//  SwiftUIView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI

struct SwiftUIView: View {
    let myArray=[1,2,3,4,5,6]
    var body: some View {
        VStack{
            ForEach(myArray,id:\.self){el in
                Text("\(el)")
                
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
