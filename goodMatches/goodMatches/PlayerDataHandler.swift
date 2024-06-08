//
//  readData.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import Foundation
import SwiftUI
import Network


class PlayerDataHandler: ObservableObject  {
    //@Published var players = [Player]()
    //@Published var dataLoaded=false
    let urlString_remote:String
    
    init(urlString_remote:String){
        self.urlString_remote=urlString_remote
    }
    
    func loadData_local() ->[Player]{
        guard let url = Bundle.main.url(forResource: "players", withExtension: "json")
            else {
                print("Json file not found")
                return []
            }
        
        let data = try? Data(contentsOf: url)
        let players = try? JSONDecoder().decode([Player].self, from: data!)
        return players ?? []
//        self.players=players ?? []
//        self.dataLoaded = !self.players.isEmpty
        
    }
    
    func loadData_remote() async throws -> [Player] {
        guard let url = URL(string: urlString_remote) else {
            throw NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])//NetworkError.invalidResponse
        }

        var myPlayers:[Player]=[]
        do {
            myPlayers = try JSONDecoder().decode([Player].self, from: data) // Since the JSON in the URL starts with array([]), we will be using [Post].self. If the JSON starts with curly braces ({}), use Post.self//                return players
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
    func add_player_remote(_ player:Player) async {
        if let request=get_url_request(urlStr: urlString_remote, requestType: "POST"){
            guard let encodedData=try? JSONEncoder().encode(player)else{return}
            do{let (data, _) = try await URLSession.shared.upload(for:request,from:encodedData)}catch{print()}
        }
    }
    
    func delete_players(_ players:[Player]) async {
        await delete_players_remote(players)
    
    }
    
    func delete_players_remote(_ players:[Player]) async {
        for player in players{
            await delete_player_remote(player)
        }
    }
    func delete_player_remote(_ player:Player) async {
        //let urlStr=urlRootStr_remote+"/players/"+player.id
        if let request=get_url_request(urlStr: urlString_remote+"/\(player.id)", requestType: "DELETE"){
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
    func get_url_request(urlStr:String, requestType:String)->URLRequest?{
        guard let url = URL(string:urlStr)
        else {
            print("Invalid URL")
            return nil
        }
        
        var request=URLRequest(url:url)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = requestType
        
        return request
    }
}


