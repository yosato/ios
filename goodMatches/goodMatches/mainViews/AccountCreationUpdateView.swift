//
//  AccountCreationView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/10/2024.
//

import SwiftUI

struct AccountCreationUpdateView: View {
    @EnvironmentObject var authService:AuthService
   // @EnvironmentObject var dataService:DataService
    @State private var email:String=""
    @State private var displayName:String=""
    @State private var password:String=""
  //  @State private var member:Member?=nil
    var entrySufficient:Bool { entriesValid() }
    var initLevels=["Prefer not to set","Beginner","Improver","Intermediate","Upper intermediate","Advanced"]
    var proposedGenders=["Prefer not to say","female","male"]
    @State private var proposedGender="Prefer not to say"
    @State private var initLevel="Prefer not to set"

    
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
                    Section("Email"){
                        TextField("email",text:$email).textInputAutocapitalization(.never)}
                    Section("Display name"){
                        TextField("under 15 characters, no double hyphen ('--')",text:$displayName).textInputAutocapitalization(.never)}
                    Picker("Proposed initial level",selection:$initLevel){
                        ForEach(initLevels,id:\.self){level in Text(level)}
                    }
                    Picker("Gender",selection:$proposedGender){
                        ForEach(proposedGenders, id:\.self){ gender in
                            Text("\(gender)")
                        }
                    }

                    Section("Password"){SecureField("password", text: $password)}
            }
                ZStack{
                    Button("Create"){
//                        var gender:Gender?
//                        switch proposedGender{
//                        case "Prefer not to say": gender=nil
//                        case "male": gender=Gender.male
//                        case "female": gender=Gender.female
//                        default: gender=nil
//                            
//                        }
//                        let meAsMember=Member(displayName:displayName,email:email)
                        Task{try? await authService.regularCreateAccount(displayName:displayName, email: email, password: password, gender:proposedGender, initLevel:(initLevel=="Prefer not to set" ? "intermediate" : initLevel))}
//                        dataService.registerMemberInFB(member:meAsMember){ error in print(error)}
                    }
                    NavigationLink(""){WelcomeView()}}.disabled(!entrySufficient)
            }.navigationTitle("Create Account").navigationBarTitleDisplayMode(.inline)
        }
   
    }
}

#Preview {
    AccountCreationUpdateView().environmentObject(AuthService())
}
