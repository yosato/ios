//
//  readData.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import Foundation
import SwiftUI
import Network
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PlayerViewModel:ObservableObject{
    @Published var currentClub:Club?=nil
    @Published var youAsPlayer:PlayerInClub?=nil
    let playerDataHandler=PlayerDataHandler()
    
    
}

enum MyError:Error{
    case hahahaError
}

struct JoinRequest:Codable{
    let memberUID:String
    let initScore:Double
    var completed:Bool=false
}

class PlayerDataHandler:ObservableObject {
    //@Published var PlayerInClubs = [PlayerInClub]()
    //@Published var dataLoaded=false
    //let urlString_remote:String
    let db=Firestore.firestore()
//    init(urlString_remote:String){
//        self.urlString_remote=urlString_remote
//    }
    
    func get_player_fromAuthUserUID(_ authUserUID:String)->(Club?,PlayerInClub?){
        var club:Club?=nil
        var playerInClub:PlayerInClub?=nil
        return (club,playerInClub)
    }

    //create player object and push it to fs
    func admit_players(members:[Member], clubUID:String, initScore:Double)->[PlayerInClub]{
        let playersToAdd=members.map{member in
            PlayerInClub(asMember:member,score:initScore,clubUID:clubUID)}
        
        let playersDocRef=self.db.collection("clubs").document(clubUID)
        playersDocRef.updateData(["players":FieldValue.arrayUnion(playersToAdd)])
        return playersToAdd
    }
    
    func add_playerInClub(_ player:PlayerInClub,clubUID:String){
        
    }
    
    func fetch_clubs_fromClubUIDs(_ clubUIDs:[String]) async throws->[Club]{
        var clubs:[Club]=[]
        for clubUID in clubUIDs{
            let docRef=self.db.collection("clubs").document(clubUID)
            
            do{ let doc=try await docRef.getDocument()
                if(doc.exists){
                    let club=try await docRef.getDocument(as:Club.self)
                    clubs.append(club)}
            }catch{print("can't fetch")}
            
        }
        return clubs
    }

    func loadClubData(clubUID:String) async throws->Club?{
        var club:Club?
        let clubRef=self.db.collection("clubs").document(clubUID)
        do{
            club=try await clubRef.getDocument(as:Club.self)
            //if(club == nil){return nil}
        }catch{
            throw MyError.hahahaError
        }
        return club
    }
    //
    func get_affiliatedClubDocIDsNames_fromAuthUserUID(_ authUID:String) async throws ->[String:String]?{
        var foundClubDocIDsNames:[String:String]=[:]
        let memberRef=self.db.collection("registeredMembers").document(authUID)
        let memberDoc=try? await memberRef.getDocument()
        if(memberDoc == nil){return nil}
        if(!memberDoc!.exists){return [:]}
        if let clubUIDs=memberDoc!.data()!["playerOf"] as? [String]{
            for clubUID in clubUIDs{
                let clubRef=self.db.collection("clubs").document(clubUID)
                let clubDoc=try? await clubRef.getDocument()
                if(clubDoc == nil){return nil}
                if let clubName=clubDoc!.data()!["name"] as? String{
                    foundClubDocIDsNames[clubUID]=clubName
                }
            }
        }else{return nil}
        return foundClubDocIDsNames
    }
    func get_userNameEmailPair_fromAuthUserUID(_ authUID:String) async throws ->(String,String)?{
        let db=Firestore.firestore()
        let docRef=db.collection("registeredMembers").document(authUID)
        do{
            let doc=try await docRef.getDocument()
            if(doc.exists){
                let displayName=doc.data()!["displayName"] as? String
                let email=doc.data()!["email"] as? String
                return (displayName!,email!)
            }else{
                print("")}
        }catch{}
        return nil
    }
    
    func request_join(member:Member,club:Club){
        guard let clubUID=club.uid else{return}
        guard let memberUID=member.uid else{return}
        let clubDocRef=self.db.collection("clubs").document(club.uid!)
        clubDocRef.updateData(
            ["joinRequests": FieldValue.arrayUnion(
                [["memberUID":memberUID, "completed":false]]
                )]
            )
    }
    
    func register_club(_ club:Club) async throws->String?{
        let db=Firestore.firestore()
        do {
            let docRef=db.collection("clubs").document()
            let docID=docRef.documentID
            
            try docRef.setData(from:club)
            
            return docID
            
        }catch{
            return nil
        }
        
    }
    
    func loadData_local() ->[PlayerInClub]{
        guard let url = Bundle.main.url(forResource: "players_test", withExtension: "json")
            else {
                print("Json file not found")
                return []
            }
        
        let data = try? Data(contentsOf: url)
        let players = try? JSONDecoder().decode([PlayerInClub].self, from: data!)
        return players ?? []
//        self.players=players ?? []
//        self.dataLoaded = !self.players.isEmpty
        
    }
    
    func loadData_remote() async throws -> [PlayerInClub] {
        guard let url = URL(string: "") else {
            throw NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])//NetworkError.invalidResponse
        }

        var myPlayers:[PlayerInClub]=[]
        do {
            myPlayers = try JSONDecoder().decode([PlayerInClub].self, from: data) // Since the JSON in the URL starts with array([]), we will be using [Post].self. If the JSON starts with curly braces ({}), use Post.self//                return players
     //       return players
        } catch let jsonError {
            print("Failed to decode json", jsonError)
        }

        return myPlayers
    }
    
//    func loadData_remote0() {
//        if let request=get_url_request(urlStr: urlString_remote, requestType: "GET"){
//            
//            let task =  URLSession.shared.dataTask(with: request){ data, response, error in
//                if let error = error {
//                    print("Error while fetching data:", error)
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                
//                    let players = try? JSONDecoder().decode([Player].self, from: data) // Since the JSON in the URL starts with array([]), we will be using [Post].self. If the JSON starts with curly braces ({}), use Post.self
//                    self.players=players ?? []
//                self.dataLoaded = !self.players.isEmpty
//
//            }
//            
//            task.resume()
//        }
//    }
//    
    
//    func get_ind_fromID(playerID:String)->Int?{
//        for (ind,player) in self.players.enumerated(){
//            if player.id==playerID{
//                return ind
//            }
//        }
//        return nil
//     
//    }
//    
    func add_player_remote(_ player:PlayerInClub) async {
        if let request=get_url_request(urlStr: "", requestType: "POST"){
            guard let encodedData=try? JSONEncoder().encode(player)else{return}
            do{let (data, _) = try await URLSession.shared.upload(for:request,from:encodedData)}catch{print()}
        }
    }
    
    func delete_players(_ players:[PlayerInClub]) async {
        await delete_players_remote(players)
    
    }
    
    func delete_players_remote(_ players:[PlayerInClub]) async {
        for player in players{
            await delete_player_remote(player)
        }
    }
    func delete_player_remote(_ player:PlayerInClub) async {
        //let urlStr=urlRootStr_remote+"/players/"+player.id
        if let request=get_url_request(urlStr: ""+"/\(player.id)", requestType: "DELETE"){
            guard let encodedData=try? JSONEncoder().encode(player)else{return}
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                if let error = error {
                    print("Error while fetching data:", error)
                    return
                }
                
                guard let data = data else {
                    return
                }
                
            }
            
            task.resume()
        }
    }
}


