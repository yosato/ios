//
//  LoginView.swift
//  onlineJanken
//
//  Created by Yo Sato on 01/08/2024.
//

import SwiftUI

struct LoginView: View {
        @State private var email: String = ""
        @State private var password: String = ""
        @EnvironmentObject var authService: AuthService
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color.gray
                        .ignoresSafeArea()
                        .opacity(0.5)
                    
                    VStack {
                        TextField("Email", text: $email).textInputAutocapitalization(.never)
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Login") {
                            authService.regularSignIn(email: email, password: password) { error in
                                if let e = error {
                                    print(e.localizedDescription)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        HStack {
                            Text("Don't have an account?")
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Create Account").foregroundColor(.blue)
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }

#Preview {
    LoginView()
}
