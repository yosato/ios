//
//  DataHandler.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct GroupSession: Codable, Identifiable, Equatable{
    var documentID:String?=nil
    let sessionName: String
    let organiser:Member
    let invitees:Set<Member>
    var createdAt=Date()
    var id: String{
        documentID ?? UUID().uuidString
    }
    var members:Set<Member> {Set([organiser]).union(invitees)}
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
    var uid:String?=nil
    var id:String {displayName+"--"+email}
    let groupsJoined:[Group]=[]
    var onlineP:Bool=false
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

}

struct Group{
    let members:[Member]
}

func docSnapshot2session(snapshot:QueryDocumentSnapshot)->GroupSession?{
    let dictionary=snapshot.data()
    guard let sessionName=dictionary["sessionName"] as? String,
          let organiser=dictionary["organiser"] as? Member,
          let invitees=dictionary["invitees"] as? Set<Member>
    else {
        return nil
    }
    return GroupSession(documentID: snapshot.documentID, sessionName: sessionName,organiser:organiser,invitees:invitees)
}
func snapshot2member(snapshot:QueryDocumentSnapshot)->Member?{
    let dictionary=snapshot.data()
    guard let displayName=dictionary["displayName"] as? String, let email=dictionary["email"] as? String else {
        return nil
    }
    return Member(displayName: displayName, email: email, uid: snapshot.documentID)
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


class DataService:ObservableObject{
    
    @Published var ourGroupSession:GroupSession?=nil
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
//    func fetchSessionsFromFB() async throws{
//        let db=Firestore.firestore()
//        let snapshot=try await db.collection("groupSessions").getDocuments()
//        self.groupSessions=snapshot.documents.compactMap { snapshot in
//            docSnapshot2session(snapshot:snapshot)
//        }
//    }

    func get_currentMember_withEmail(_ email:String)-> Member?{
        if(self.registeredMembers.isEmpty){
            return nil}else{
                let hits=self.registeredMembers.filter{member in member.email==email}
                if(hits.count != 1){
                    return nil
                }else{return hits.first!}
            }
    }
    func fetchYourGroupSessionFromFS(_ email:String) async throws ->GroupSession?{
        let db=Firestore.firestore()
        let groupSessionsCollection=db.collection("groupSessions")
        let allSessionsDocuments=try await groupSessionsCollection.getDocuments()
        //let groupSessionsInvitees=try await groupSessionsCollection.document()
        db.collection("groupSessions").document()
        let selectedSessions=allSessionsDocuments.documents.compactMap{snapshot in
            docSnapshot2session(snapshot:snapshot)}
        var selectedSession:GroupSession?
        for session in selectedSessions{
            let emails=session.invitees.map{invitee in invitee.email}
            if(emails.contains(email)){selectedSession=session;break}
            selectedSession=nil
        }
        self.ourGroupSession=selectedSession
        return ourGroupSession
        }

    func sendMessageToFB(text:String,session:GroupSession,completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        guard let sessionDocID=session.documentID else {return}
        db.collection("sessions").document(sessionDocID).collection("messages").addDocument(data:["chatText":text]){ error in completion(error) }
        
    }
    func addMemberToSessionInFB(member:Member,sessionDocID:String,completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
//        guard let sessionDocID=session.documentID else {return}
        db.collection("sessions").document(sessionDocID).collection("members").addDocument(data:["name":member.displayName,"email":member.email]){ error in completion(error) }
        
    }

    
    
    func createSessionInFB(session:GroupSession, completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        var docRef:DocumentReference?=nil
        docRef=db.collection("groupSessions")
            .addDocument(data:["sessionName":session.sessionName,"organiserEmail":session.organiser.email,"createdAt":session.createdAt]){ error in
                if(error != nil){completion(error)}else{
                    if let docRef{
                        db.collection("groupSessions").document(docRef.documentID).collection("organiser").document(session.organiser.uid!).setData(["uid":session.organiser.uid!])
                        let inviteeUIDs=session.invitees.map{invitee in invitee.uid!}
                        for inviteeUID in inviteeUIDs{
                            db.collection("groupSessions").document(docRef.documentID).collection("invitees").document(inviteeUID).setData(["uid":inviteeUID])}
                        var newSession=session
                        newSession.documentID=docRef.documentID
                        self.ourGroupSession=newSession
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
                        newMember.uid=docRef.documentID
                        self.registeredMembers.append(newMember)
                    }
                }
            }
    }

    
    func listenForMessagesInSession(in session:GroupSession){
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
  //  @Published var userName:String? = nil
    @Published var currentUser:User? = nil
    @Published var currentMember:Member?=nil
    init() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.signedIn = true
//                self.userName=user?.displayName ?? ""
                self.currentUser=auth.currentUser!
                print("Auth state changed, is signed in")
            } else {
                self.signedIn = false
                print("Auth state changed, is signed out")
            }
        }
    }
    
    // MARK: - Password Account
    func regularCreateAccount(displayName:String, email: String, password: String) async throws {
        do {let authResult=try await Auth.auth().createUser(withEmail: email, password: password)
            
            self.currentUser=authResult.user
            try await Firestore.firestore().collection("registeredMembers").document(currentUser!.uid).setData(["displayName":displayName,"email":email,"uid":currentUser!.uid,"createdAt":            currentUser!.metadata.creationDate!],merge:false)
        } catch{
            print("account creation failed")
            return
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
                  Firestore.firestore().collection("registeredMembers")
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


