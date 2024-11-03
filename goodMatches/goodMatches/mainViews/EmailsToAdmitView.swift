//
//  EmailsToAdmitView.swift
//  goodMatches
//
//  Created by Yo Sato on 02/11/2024.
//

import SwiftUI

struct EmailsToAdmitView: View {
    @State private var email=""
    @State private var emailsToRegister:[String]=[]
    @State private var newEmails:[String]=[]
    @State private var registeredEmails:[String]=["aaa@aaa","iii@iii","uuu@uuu"]
    @State private var emailAlreadyExists=false
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    TextField("input new email here",text:$email).onSubmit{ if(!registeredEmails.contains(email)){emailsToRegister.append(email)}else{emailAlreadyExists=true}; email=""}
                Section((!emailsToRegister.isEmpty ? "To be approved" : "")){
                    if(!emailsToRegister.isEmpty){ForEach(emailsToRegister,id:\.self){email in
                        Text(email)
                    }
                        Button("Approve"){}
                    }
                }
                    Section("Already approved"){
                        HStack{ForEach(registeredEmails,id:\.self){
                            Text($0)
                        }}}

                }
            }.navigationTitle("Add pproved emails").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EmailsToAdmitView()
}
