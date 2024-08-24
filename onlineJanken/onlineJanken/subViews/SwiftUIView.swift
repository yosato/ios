//
//  SwiftUIView.swift
//  onlineJanken
//
//  Created by Yo Sato on 16/08/2024.
//

import SwiftUI

struct SwiftUIView: View {
    @State var anim=1.0
    var body: some View {
        Button("aaa"){anim+=1}.padding(50).background(.red).clipShape(Circle()).scaleEffect(anim).animation(.easeInOut(duration:3),value:anim)
    }
}

#Preview {
    SwiftUIView()
}
