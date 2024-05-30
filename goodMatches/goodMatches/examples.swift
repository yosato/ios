//
//  examples.swift
//  goodMatches
//
//  Created by Yo Sato on 04/03/2024.
//

import Foundation


let letters = Array("ABCDEFGHIJKLMNOPQRST").map{String($0)}
let numbers=Array(0..<20)

func create_fakeplayers(letters:[String],numbers:[Int])-> [Player]{
    var fakePlayers=[Player]()
    for (cntr,(letter,number)) in zip(letters,numbers).enumerated(){
        let gender=(cntr%2==0 ? "male" : "female")
        //fakePlayers.append(Player(name:letter,score:number,gender:gender))
    }
    return fakePlayers
}

let fakePlayers=create_fakeplayers(letters: letters, numbers: numbers)
