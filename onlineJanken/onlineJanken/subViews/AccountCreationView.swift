//
//  AccountCreationView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI

struct AccountCreationView: View {
    @EnvironmentObject var authService:AuthService
    @EnvironmentObject var dataService:DataService
    @State private var email:String=""
    @State private var displayName:String=""
    @State private var password:String=""
    @State private var member:Member?=nil
    var entrySufficient:Bool { entriesValid() }
    
    func looksLikeValidEmail(_ input:String)->Bool{
        var bool=false
        if(input.contains("@") && input.contains(".") && !input.hasPrefix("@") && !input.hasPrefix(".") && !input.hasSuffix("@") && !input.hasSuffix(".")){
            bool=true
        }
        return bool
    }
    func entriesValid()->Bool{
        var bool=false
        if(looksLikeValidEmail(email) && (!displayName.isEmpty && !displayName.contains("--")) && !password.isEmpty ){bool=true}
        return bool
    }
    
    var body: some View {
        NavigationStack{
            VStack{            
                Form{
                    Section("メールアドレス"){
                        TextField("",text:$email).textInputAutocapitalization(.never)}
                    Section("表示名（15文字以内、二重ハイフン（'--'）なし）"){
                        TextField("",text:$displayName).textInputAutocapitalization(.never)}
                    Section("パスワード"){SecureField("パスワード", text: $password)}
            }
                ZStack{
                    Button("作成"){
                        let meAsMember=Member(displayName:displayName,email:email)
                        Task{try? await authService.regularCreateAccount(displayName:displayName, email: email, password: password)}
                        dataService.registerMemberInFB(member:meAsMember){ error in print(error)
                            
                        }
                    }
                    NavigationLink(""){WelcomeView()}}.disabled(!entrySufficient)
            }.navigationTitle("新規アカウント作成").navigationBarTitleDisplayMode(.inline)
        }
   
    }
}

#Preview {
    AccountCreationView().environmentObject(AuthService()).environmentObject(DataService())
}
