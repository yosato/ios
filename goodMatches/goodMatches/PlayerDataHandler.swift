//
//  readData.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import Foundation

//@MainActor
class PlayerDataHandler: ObservableObject  {
    @Published var players = [Player]()
    let urlRootStr_remote="http://127.0.0.1"
    
    func loadData_local()  {
        guard let url = Bundle.main.url(forResource: "players", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        let data = try? Data(contentsOf: url)
        let players = try? JSONDecoder().decode([Player].self, from: data!)
        self.players = players!
        
    }
    func loadData_remote() async {
        
        guard let url = URL(string:"http://127.0.0.1:5000/players")
            else {
                print("Invalid URL")
                return
            }
        
        var request=URLRequest(url:url)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                print("Error while fetching data:", error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let players = try JSONDecoder().decode([Player].self, from: data) // Since the JSON in the URL starts with array([]), we will be using [Post].self. If the JSON starts with curly braces ({}), use Post.self
                self.players=players
            } catch let jsonError {
                print("Failed to decode json", jsonError)
            }
            
        }
        
        task.resume()
    }
    
    func add_player(_ player:Player){
        self.players.append(player)
    }
    
    func delete_player_local(playerID:String){
        if let ind=self.get_ind_fromID(playerID:playerID){
            self.players.remove(at: ind)}else{print("not found")}
    }
    
    func get_ind_fromID(playerID:String)->Int?{
        for (ind,player) in self.players.enumerated(){
            if player.id==playerID{
                return ind
            }
        }
        return nil
     
    }
    
    func add_player_remote(_ player:Player) async {
        guard let url = URL(string:"http://127.0.0.1:5000/players")
        else {
            print("Invalid URL")
            return
        }

        var request=URLRequest(url:url)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        guard let encodedData=try? JSONEncoder().encode(player)else{return}

        do{let (data, _) = try await URLSession.shared.upload(for:request,from:encodedData)}catch{print()}
    }

    func delete_player_remote(_ player:Player) async {
    //let urlStr=urlRootStr_remote+"/players/"+player.id
        guard let encodedData=try? JSONEncoder().encode(player)else{return}
        
        guard let url = URL(string:"http://127.0.0.1:5000/players/\(player.id)")
            else {
                print("Invalid URL")
                return
            }
        
        var request=URLRequest(url:url)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"

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
        self.delete_player_local(playerID: player.id)
    }

    func delete_players_remote(_ players:[Player]) async {
        for player in players{
            await delete_player_remote(player)
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


