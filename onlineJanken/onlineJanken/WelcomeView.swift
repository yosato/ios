//
//  WelcomeView.swift
//  onlineJanken
//
//  Created by Yo Sato on 31/07/2024.
//

import SwiftUI

// to come to this view first 
struct WelcomeView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authService: AuthService

    var body: some View {
        
        VStack {
            LogoView()
            NavigationView {
                       ZStack {
                           Color.gray
                               .ignoresSafeArea()
                               .opacity(0.5)
                           
                           VStack {
                               Spacer()
                               NavigationLink("アカウントを作る（初めての方）") {
                                   AccountCreationView()}
                               Spacer()
                               
                               Text("アカウントのある方").padding()
                               
                               TextField("メールアドレス", text: $email).textInputAutocapitalization(.never)
                                   .textFieldStyle(.roundedBorder)
                               SecureField("パスワード", text: $password)
                                   .textFieldStyle(.roundedBorder)
                               
                               HStack{
                                   Button("ログイン"){  authService.regularSignIn(email: email, password: password) { error in
                                       if let e = error {
                                           print(e.localizedDescription)
                                       }
                                   }
                                   }
                                                                       
                                .controlSize(.large).padding()
                               }
                               Spacer()
                           }
                           .padding()
                       }
            }
        }
    }
}

#Preview {
    WelcomeView().environmentObject(AuthService())
}
