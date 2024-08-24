//
//  HomeView.swift
//  onlineJanken
//
//  Created by Yo Sato on 31/07/2024.
//

import SwiftUI

struct HomeView: View {
//    @EnvironmentObject var authService:AuthService
    @EnvironmentObject var dataService:DataService
    var invited=false
    
    var body: some View {
        if(!invited){
            OrganizeView().environmentObject(dataService)
          //  JankenSessionView().environmentObject(JankenSessions())
        }
        else{
            ParticipateView().environmentObject(dataService)
        }
        
    }
    }

#Preview {
    HomeView().environmentObject(DataService())
}
