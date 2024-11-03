//
//  WelcomeView.swift
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
    @State private var showAlertLoginFailure=false

    var body: some View {
        
            NavigationStack {
                VStack {
                    Spacer()
                    LogoView()
                       ZStack {
                           Color.gray
                               .ignoresSafeArea()
                               .opacity(0.5)
                           
                           VStack {
                               Spacer()
                               NavigationLink("Create account") {
                                   AccountCreationUpdateView()}
                               Spacer()
                               
                               Text("For existing members").padding()
                               
                               TextField("email", text: $email).textInputAutocapitalization(.never)
                                   .textFieldStyle(.roundedBorder)
                               SecureField("password", text: $password)
                                   .textFieldStyle(.roundedBorder)
                               
                               HStack{
                                   Button("Log in"){
                                       if(!emailLookingGood(email)){print("input doesn't look good")}
                                       Task{do{
                                           try await authService.regularSignIn(email: email, password: password)
                                           goToAfterLogin=true
                                       }catch{showAlertLoginFailure=true;print("login failed")}
                                       }
                                   }.disabled(email.isEmpty || password.isEmpty || !emailLookingGood(email))
                                       .controlSize(.large).padding()
                                   
                               }.alert("error", isPresented: $showAlertLoginFailure) {Button("OK",role:.cancel){}} message: { Text("Email or password incorrect") }
                               Spacer()
                               Button("Reset password"){Task{try await authService.resetPassword(email: email)}
                               }.disabled(!emailLookingGood(email))
                                   .padding()
                               
                           }
                           .padding()
                       }
            }
        }
    }
    
    func emailLookingGood(_ input:String)-> Bool{
        if(!input.contains(/[^@]+@[^@]+/) || !input.contains(".")){return false}
        return true
    }
}

#Preview {
    WelcomeView().environmentObject(AuthService())
}
