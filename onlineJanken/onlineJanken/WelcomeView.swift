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
    @State private var goToAfterLogin=false

    var body: some View {
        
        VStack {
            LogoView().frame(maxHeight:100)
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
                                   Button("ログイン"){
                                       if(!emailLookingGood(email)){print("input doesn't look good")}
                                       Task{do{
                                           try await authService.regularSignIn(email: email, password: password)
                                           goToAfterLogin=true
                                       }catch{print("login failed")}
                                       }
                                   }.disabled(email.isEmpty||password.isEmpty)
                                .controlSize(.large).padding()
                               }
                               Spacer()
                           }
                           .padding()
                       }
            }
        }
    }
    
    func emailLookingGood(_ input:String)-> Bool{
        if(!input.contains("@") && input.contains(".")){return false}
        return true
    }
}

#Preview {
    WelcomeView().environmentObject(AuthService())
}
