//
//  LogoView.swift
//  onlineJanken
//
//  Created by Yo Sato on 06/08/2024.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        Text("どこでもじゃんけん").font(.title).bold()
        Image("janken")
    }
}

#Preview {
    LogoView()
}
