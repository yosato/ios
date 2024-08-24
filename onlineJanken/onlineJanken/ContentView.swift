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
  //  @EnvironmentObject var jankenSessions:JankenSessions
    var body: some View {
        VStack{
            if(authService.signedIn){
                if(!is_invited(authService.userName!)){
                    OrganizeView().environmentObject(dataService)
                }else{
                    ParticipateView().environmentObject(dataService)
                }
            } else {
//                LogoView()
//                JankenSessionView().environmentObject(jankenSessions)
                WelcomeView().environmentObject(authService).environmentObject(dataService)
            }
        }
    }
    func is_invited(_ member:String)->Bool{
        return false
    }
}


#Preview {
    ContentView().environmentObject(AuthService()).environmentObject(DataService())
}
