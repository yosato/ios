//
//  ranking.swift
//  goodMatches
//
//  Created by Yo Sato on 13/03/2024.
//

import Foundation

func get_elo_prob(favourite:Player, against:Player, n:Double=400.0)-> Double{
    let scoreDiff=Double(against.score-favourite.score)
    let divisor=1.0+pow(10.0,scoreDiff/n)
    return Double(1.0/divisor)
}



