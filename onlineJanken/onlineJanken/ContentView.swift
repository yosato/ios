//
//  ContentView.swift
//  onlineJanken
//
//  Created by Yo Sato on 31/07/2024.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var authService:AuthService
    @EnvironmentObject var dataService:DataService

    var body: some View {
        VStack{
            if(!authService.signedIn){
                WelcomeView().environmentObject(authService)
            }else{
                if let currentUser=authService.currentUser {
                    AfterLogInView(yourCredential:currentUser).environmentObject(authService).environmentObject(dataService)
                }
        }
        //                LogoView()
        //                JankenSessionView().environmentObject(jankenSessions)
    
        }
    }
}


#Preview {
    ContentView().environmentObject(AuthService()).environmentObject(DataService())
}
