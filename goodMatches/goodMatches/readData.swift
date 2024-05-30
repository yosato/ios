//
//  readData.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import Foundation

class ReadData: ObservableObject  {
    @Published var players = [Player]()
    
    init(){
        loadData()
    }
    
    func loadData()  {
        guard let url = Bundle.main.url(forResource: "players", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        let data = try? Data(contentsOf: url)
        let players = try? JSONDecoder().decode([Player].self, from: data!)
        self.players = players!
        
    }
    func add_player(_ player:Player){
        self.players.append(player)
    }
}


