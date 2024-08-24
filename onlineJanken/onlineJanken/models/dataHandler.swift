//
//  DataHandler.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Session: Codable, Identifiable, Equatable{
    var documentID:String?=nil
    let sessionName: String
    var members=Set<Member>()
    var id: String{
        documentID ?? UUID().uuidString
    }
    
    func toDictionary()->[String:String]{
        return ["name":sessionName]
    }
}

struct Member:Identifiable,Hashable,Equatable,Codable{
    enum CodingKeys:String,CodingKey{
        case displayName
        case email
    }
    static func == (lhs: Member, rhs: Member) -> Bool {
        lhs.id==rhs.id
    }
    
    let displayName:String
    let email:String
    let uid:String?=nil
    var id:String {displayName+"--"+email}
    var documentID:String?=nil
    let groupsJoined:[Group]=[]
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

}

struct Group{
    let members:[Member]
}

func docSnapshot2session(snapshot:QueryDocumentSnapshot)->Session?{
    let dictionary=snapshot.data()
    guard let sessionName=dictionary["sessionName"] as? String else {
        return nil
    }
    return Session(documentID: snapshot.documentID, sessionName: sessionName)
}
func snapshot2member(snapshot:QueryDocumentSnapshot)->Member?{
    let dictionary=snapshot.data()
    guard let displayName=dictionary["displayName"] as? String, let email=dictionary["email"] as? String else {
        return nil
    }
    return Member(displayName: displayName, email: email, documentID: snapshot.documentID)
}

struct ChatMessage:Codable,Identifiable,Equatable{
    var documentID:String?
    let text:String
    let uid:String
    let displayName:String
    var dateCreated:Date=Date()
    var profilePhotoURLString:String=""
    
    var profilePhotoURL:URL? {profilePhotoURLString.isEmpty ? nil : URL(string:profilePhotoURLString)}
    
    var id:String{
        documentID ?? UUID().uuidString
    }
    
    func toDictionary()-> [String:Any]{
        return [
            "text":text,
            "uid":uid,
            "dateCreated":dateCreated,
            "displayName":displayName,
            "profilePhotoURLString":profilePhotoURLString
        ]
    }

}


func snapshot2ChatMessage(_ snapshot:QueryDocumentSnapshot)->ChatMessage?{
   let myDict=snapshot.data()
   guard let text=myDict["text"] as? String,
         let uid=myDict["uid"] as? String,
         let dateCreated=(myDict["dateCreated"] as? Timestamp)?.dateValue(),
         let displayName=myDict["displayName"] as? String
   else{return nil}
    return ChatMessage(documentID: snapshot.documentID, text: text, uid: uid, displayName: displayName, dateCreated:dateCreated)
}

@MainActor
class DataService:ObservableObject{
    
    @Published var sessions:[Session]=[]
    @Published var messagesInSession=[ChatMessage]()
    @Published var registeredMembers:[Member]=[]
    
    
    var firestoreListener: ListenerRegistration?

    
    func updateDisplayName(for user:User,displayName:String) async throws{
        let request=user.createProfileChangeRequest()
        request.displayName=displayName
        try await request.commitChanges()
    }
    
    func fetchMembersFromFB() async throws{
        let db=Firestore.firestore()
        let snapshot=try await db.collection("registeredMembers").getDocuments()
        let registeredMemberDocs=snapshot.documents
        let fetchedMembers=registeredMemberDocs.compactMap{ snapshot in snapshot2member(snapshot:snapshot) }
        self.registeredMembers=fetchedMembers
    }
    func fetchSessionsFromFB() async throws{
        let db=Firestore.firestore()
        let snapshot=try await db.collection("sessions").getDocuments()
        self.sessions=snapshot.documents.compactMap { snapshot in
            docSnapshot2session(snapshot:snapshot)
        }
    }

    func sendMessageToFB(text:String,session:Session,completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        guard let sessionDocID=session.documentID else {return}
        db.collection("sessions").document(sessionDocID).collection("messages").addDocument(data:["chatText":text]){ error in completion(error) }
        
    }

    func createSessionInFB(session:Session, completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        var docRef:DocumentReference?=nil
        docRef=db.collection("sessions")
            .addDocument(data:["name":session.sessionName]){ error in
                if(error != nil){completion(error)}else{
                    if let docRef{
                        var newSession=session
                        newSession.documentID=docRef.documentID
                        self.sessions.append(newSession)
                    }
                }
            }
    }
    func registerMemberInFB(member:Member, completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        var docRef:DocumentReference?=nil
        docRef=db.collection("registeredMembers")
            .addDocument(data:["displayName":member.displayName,"email":member.email]){ error in
                if(error != nil){completion(error)}else{
                    if let docRef{
                        var newMember=member
                        newMember.documentID=docRef.documentID
                        self.registeredMembers.append(newMember)
                    }
                }
            }
    }

    
    func listenForMessagesInSession(in session:Session){
        let db=Firestore.firestore()
        self.messagesInSession.removeAll()
        guard let docID=session.documentID else {return}
        self.firestoreListener=db.collection("sessions")
            .document(docID)
            .collection("messages")
            .order(by:"dateCreated",descending: false)
            .addSnapshotListener{ [weak self] snapshot, error in
                guard let snapshot=snapshot else{
                     print("Error fetching snapshot \(error!)")
                    return
                }
                snapshot.documentChanges.forEach{ change in
                    if(change.type == .added){
                        let chatMessage=snapshot2ChatMessage(change.document)
                        if let chatMessage {
                            let exists=self?.messagesInSession.contains(where:{msg in msg.documentID==chatMessage.documentID})
                            if !exists!{
                                self?.messagesInSession.append(chatMessage)
                            }
                        }
                    }
                    
                }
                
                 
            }
        
    }

    
}



class AuthService: ObservableObject{
    @Published var signedIn:Bool=false
    @Published var userName:String? = nil
    init() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.signedIn = true
                self.userName=user?.displayName ?? ""
                print("Auth state changed, is signed in")
            } else {
                self.signedIn = false
                print("Auth state changed, is signed out")
            }
        }
    }
    
    // MARK: - Password Account
        func regularCreateAccount(email: String, password: String) {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    
                } else {
                    print("Successfully created password account")
                }
            }
        }
        
    //MARK: - Traditional sign in
      // Traditional sign in with password and email
      func regularSignIn(email:String, password:String, completion: @escaping (Error?) -> Void) {
          Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
              if let e = error {
                  completion(e)
              } else {
                  print("Login success")
                  
                  completion(nil)
              }
          }
      }
      
      // Regular password acount sign out.
      // Closure has whether sign out was successful or not
      func regularSignOut(completion: @escaping (Error?) -> Void) {
          let firebaseAuth = Auth.auth()
          do {
              try firebaseAuth.signOut()
              completion(nil)
          } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            completion(signOutError)
          }
      }
    
}


