//
//  DataHandler.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import jankenModels

struct GroupSession: Codable,Identifiable{
    let sessionName: String
    let organiserUID:String
    let inviteeUIDs:Set<String>
    var id:String?=nil
    var createdAt=Date()
    var rounds:[JankenRound]=[]
    var isCompleted:Bool=false
    
//    var id: String{
//        documentID ?? UUID().uuidString
//    }
    var memberUIDs:Set<String> {Set([organiserUID]).union(inviteeUIDs)}
    
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
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

    func convertIntoParticipant() -> Participant{
        return Participant(displayName:self.displayName,email:self.email)
    }
    
}

struct Group{
    let members:[Member]
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
    @Published var onlineUserIDs:[String]=[]
    
    var firestoreMessageListener: ListenerRegistration?
    var firestoreUserListener: ListenerRegistration?
    
    private let FSDB=Firestore.firestore()
        
    private func getMatchedDocRefFromFSCollection(matching:String, collectionName:String)-> DocumentReference?{
        return Firestore.firestore().collection(collectionName).document(matching)
    }
    // initial creation of a session. empty in that no janken has been done and hence no rounds are assigned. returning the docref to allow you to populate crucial docID locally
    func createEmptySessionInFB(session:GroupSession) async throws-> DocumentReference?{
        let db=Firestore.firestore()
        var docRef:DocumentReference?=nil
        do {let _=try await db.collection("groupSessions")
            .addDocument( data:["sessionName":session.sessionName,"organiserUID":session.organiserUID,"inviteeUIDs":session.inviteeUIDs,"createdAt":session.createdAt,"isCompleted":false])}
//        do {let docRef=try await db.collection("groupSessions")
//            .addDocument( data:["sessionName":session.sessionName,"organiserUID":session.organiserUID,"inviteeUIDs":session.inviteeUIDs,"createdAt":session.createdAt,"isCompleted":false])}
        catch{
                throw URLError(.badServerResponse)
            }
        return docRef
    }
    func updateSessionInFB() async throws{
        let db=Firestore.firestore()
        guard let grSession=self.ourGroupSession else {return}
        guard let grSessionID=grSession.id else {return}
        //var docRef:DocumentReference?=nil
        do {if let docRef=getMatchedDocRefFromFSCollection(matching: grSessionID, collectionName: "groupSessions") {
            try docRef.setData(from:grSession)
        }}catch{throw URLError(.badServerResponse)}
        
    }

        

    
    func updateDisplayName(for user:User,displayName:String) async throws{
        let request=user.createProfileChangeRequest()
        request.displayName=displayName
        try await request.commitChanges()
    }
    
    
    func fetch_sessionResult() async throws-> [JankenRound]{
        var rounds=[JankenRound]()
        return rounds
    }
    
    func upload_sessionRsult() async throws{
        
    }
    
    
    func fsdata2session(sessionSnapshot:QueryDocumentSnapshot) ->GroupSession?{
        if(self.registeredMembers.isEmpty){return nil}
        let dictionary=sessionSnapshot.data()
        guard let sessionName=dictionary["sessionName"] as? String,
              let createdAt=dictionary["createdAt"] as? Timestamp,
              let isCompleted=dictionary["isCompleted"] as? Bool,
              let organiserUID=dictionary["organiserUID"] as? String,
              let inviteeUIDs=dictionary["inviteeUIDs"] as? [String]
        else {
            print("session object creation failed")
            return nil
        }
        
        return GroupSession(sessionName: sessionName, organiserUID: organiserUID, inviteeUIDs: Set(inviteeUIDs), id:sessionSnapshot.documentID, createdAt:createdAt.dateValue(), isCompleted: isCompleted)
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
    func fetchYourGroupSessionsFromFS(_ uidToSearch:String) async throws ->[GroupSession]{
        let grSessions=Firestore.firestore().collection("groupSessions")
        var selectedSessions=[GroupSession]()
        do{
            let sessionsSnapshot=try await grSessions.whereField("isCompleted", isEqualTo:false).whereFilter(Filter.orFilter([
                Filter.whereField("inviteeUIDs",arrayContains:uidToSearch), Filter.whereField("organiserUID",isEqualTo:uidToSearch)
            ])).getDocuments()
            
            for sessionSnapshot in sessionsSnapshot.documents{
                if let session=fsdata2session(sessionSnapshot:sessionSnapshot){
                    selectedSessions.append(session)
                }
                
            }
        
        }catch{print(error.localizedDescription)}
//        let openSessions=openSessionsSnapshot.documents
        return selectedSessions

    }

    func sendMessageToFB(text:String,session:GroupSession,completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
        guard let sessionDocID=session.id else {return}
        db.collection("sessions").document(sessionDocID).collection("messages").addDocument(data:["chatText":text]){ error in completion(error) }
        
    }
    func addMemberToSessionInFB(member:Member,sessionDocID:String,completion:@escaping (Error?)->Void){
        let db=Firestore.firestore()
//        guard let sessionDocID=session.documentID else {return}
        db.collection("sessions").document(sessionDocID).collection("members").addDocument(data:["name":member.displayName,"email":member.email]){ error in completion(error) }
        
    }

//        { error in
//                if(error != nil){completion(error)}else{
//                    if let docRef{
//                        let inviteeUIDs=session.invitees.map{invitee in invitee.uid!}
//                        for inviteeUID in inviteeUIDs{
//                            db.collection("groupSessions").document(docRef.documentID).collection("invitees").document(inviteeUID).setData(["uid":inviteeUID])}
//                        var newSession=session
//                        newSession.id=docRef.documentID
//                        self.ourGroupSession=newSession
//                    }
//                }
//            }
//    }

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

    func uid2member(_ uid:String)-> Member?{
        return self.registeredMembers.first(where:{member in member.uid==uid})
    }
    
    func listenForUsers(){
        let db=Firestore.firestore()
        self.onlineUserIDs.removeAll()
//        guard let docID=session.id else {return}
        self.firestoreUserListener=db.collection("onlineUsers")
            .addSnapshotListener{ [weak self] snapshot, error in
                guard let snapshot=snapshot else{
                     print("Error fetching snapshot \(error!)")
                    return
                }
                snapshot.documentChanges.forEach{ change in
                    if(change.type == .added){
                        self?.onlineUserIDs.append( change.document.documentID)}
                        else if(change.type == .removed){
                            self?.onlineUserIDs.removeAll{uid in change.document.documentID==uid}
                        }
                    }
                    
                }
                
                 
            }
        
    

    
    
    func listenForMessagesInSession(in session:GroupSession){
        let db=Firestore.firestore()
        self.messagesInSession.removeAll()
        guard let docID=session.id else {return}
        self.firestoreMessageListener=db.collection("sessions")
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


