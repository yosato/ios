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
func get_elo_prob(favourite:Team, against:Team, n:Double=400.0)-> Double{
    let scoreDiff=Double(against.meanScore-favourite.meanScore)
    let divisor=1.0+pow(10.0,scoreDiff/n)
    return Double(1.0/divisor)
}

func get_elo_update_value(winningPlayer:Player, against:Player, result:(Int,Int), k:Int=32)-> Double{
    let resultRate=Double(result.0/(result.0+result.1))
    let expectedProb=get_elo_prob(favourite:winningPlayer,against:against)
    return Double(k)*(resultRate-expectedProb)
}

func get_elo_update_value(winningTeam:Team, against:Team, result:(Int,Int), k:Int=32)-> Double{
    let resultRate=Double(result.0/(result.0+result.1))
    let expectedProb=get_elo_prob(favourite:winningTeam,against:against)
    return Double(k)*(resultRate-expectedProb)
}



