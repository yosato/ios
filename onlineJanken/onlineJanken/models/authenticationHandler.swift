//
//  authenticationHandler.swift
//  onlineJanken
//
//  Created by Yo Sato on 20/10/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth



@MainActor
final class AuthViewModel:ObservableObject{
    
}

final class AuthService: ObservableObject{
    @Published var signedIn:Bool=false
  //  @Published var userName:String? = nil
    @Published var currentUser:User? = nil
//    @Published var currentMember:Member?=nil
    
    
    init() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if(user != nil && auth.currentUser!.isEmailVerified) {
                    self.currentUser=auth.currentUser!
                    self.signedIn = true
                    print("Auth state changed, is signed in")
            } else {
                self.signedIn = false
                print("Auth state changed, is signed out")
            }
        }

    }
    
    func regularCreateAccount(displayName:String, email: String, password: String, gender:String="", initLevel:String="") async throws {
        do {let authResult=try await Auth.auth().createUser(withEmail: email, password: password)
            let hello=try await Auth.auth().currentUser!.sendEmailVerification()
            
            var user=authResult.user
            while(!user.isEmailVerified){
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await user.reload()
//                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            self.currentUser=authResult.user

            print("email verified")
            self.signedIn=true
            // we create a FS user at account creation too
            try await Firestore.firestore().collection("registeredMembers").document(currentUser!.uid).setData(["displayName":displayName,"email":email,"uid":currentUser!.uid,"createdAt":            currentUser!.metadata.creationDate!,"initLevel":initLevel,"gender":gender],merge:false)
        } catch{
            print("account creation failed")
            return
        }
    }
    
      // Traditional sign in with password and email
      func regularSignIn(email:String, password:String) async throws {
          do {let authResult=try await Auth.auth().signIn(withEmail: email, password: password)
              let user=authResult.user
              self.currentUser=user
   
//              try await db.child("userStatuses").child(user.uid).child("status").setValue("online")
              
              try await Firestore.firestore().collection("onlineUsers").document(currentUser!.uid).setData(["since":Date()])
              print("logged in")
          }catch{
              print(error.localizedDescription)
              throw URLError(.badServerResponse)
              }
      }
      
    func resetPassword(email:String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
      // Regular password acount sign out.
      // Closure has whether sign out was successful or not
      func regularSignOut() async throws {
          let firebaseAuth = Auth.auth()
          do {
              try firebaseAuth.signOut()
              try await Firestore.firestore().collection("onlineUsers").document(currentUser!.uid).delete()
          } catch {
              throw URLError(.badServerResponse)
          }
      }
    
    
}


