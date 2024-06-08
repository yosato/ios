//
//  ResultModel.swift
//  goodMatches
//
//  Created by Yo Sato on 21/05/2024.
//

import Foundation

func get_elo_prob(favourite:Team, against:Team, n:Double=200.0)-> Double{
    let scoreDiff=Double(favourite.meanScore-against.meanScore)
    let divisor=1.0+pow(10.0,scoreDiff/n)
    return Double(1.0/divisor)
}

func get_elo_update_value(winningTeam:Team, against:Team, result:(Int,Int), k:Int=7)-> Double{
    assert(result.0>=result.1)
    let resultRate=0.1*Double(result.0-result.1)+0.7
    let weight=(winningTeam.players.count==4 ? 0.8 : 0.6)
    let expectedProb=get_elo_prob(favourite:winningTeam,against:against)
    return Double(k)*expectedProb*resultRate*weight
}

class MatchResults:ObservableObject{
    @Published var results=[MatchSetResult]()
    var lastCompleted:Bool? {!self.results.isEmpty ? self.results.last!.completed : nil}
    
    func get_matchresult_byID(_ matchID:String)-> MatchResult?{
        for matchSetResult in self.results{
            for matchResult in matchSetResult.matchResults{
                if matchResult.id==matchID{
                    return matchResult
                }
            }
        }
        return nil
    }
    
    func add_matchResult(_ matchResult:MatchResult, sizedCourtCounts:[Int:Int]){
        if let resultInd=get_rightMatchResultInd(matchResult.matchSetInd){
            self.results[resultInd].matchResults.append(matchResult)
        }else{
            var matchSetResult=MatchSetResult(sizedCourtCounts:sizedCourtCounts)
            matchSetResult.matchResults.append(matchResult)
            self.results.append(matchSetResult)
        }
    }
    
    func get_rightMatchResultInd(_ ind:Int)->Int?{
        for matchSetResult in self.results{
            if ind==matchSetResult.matchSetInd{
                return ind
            }
        }
        return nil
    }
}

struct MatchSetResult:Identifiable{
    let sizedCourtCounts:[Int:Int]
    var matchResults=[MatchResult]()
   //  assert(matchResults.map{matchResult in matchResult.matchSetInd})
    var matchSetInd:Int? {!matchResults.isEmpty ? matchResults[0].matchSetInd : nil}
    var id:String {matchResults.map{matchResult in matchResult.id}.joined(separator:"--")}
    var completed:Bool {matchResults.count==sizedCourtCounts.values.reduce(0){$0+$1}}
    var yetToStart:Bool {matchResults.isEmpty}
    var underway:Bool {!yetToStart && !completed}
}

struct MatchResult:Identifiable,Equatable{
    static func == (lhs: MatchResult, rhs: MatchResult) -> Bool {
        lhs.id==rhs.id
    }
    let matchSetInd:Int
    let match:Match
    // needs to be aligned with match.teams.0/1
    var scores:(Int,Int)
    var id:String {match.id+"__"+String(matchSetInd)}
    var drawnP:Bool {scores.0==scores.1}
    var winningInd:Int? {drawnP ? nil : (scores.0>scores.1 ? 0 : 1)}
    
    func prettystring()->String{
        let team0Str=match.teams.0.id
        let team1Str=match.teams.1.id
        let scoreStr=(winningInd==0 ? "\(scores.0)-\(scores.1)" : "\(scores.1)-\(scores.0)")
        var prettyString:String=""
        if(drawnP){prettyString+="\(team0Str) and \(team1Str) drew with \(scoreStr)"}else{
            let (winningTeamStr,losingTeamStr)=(winningInd==0 ? (team0Str,team1Str) :(team1Str,team0Str))
            prettyString+="\(winningTeamStr) bt \(losingTeamStr) by \(scoreStr)"
        }
        return prettyString
    }
}

func get_matchresult(matchSetInd:Int,match:Match,scores:(Int,Int))-> MatchResult{
    return MatchResult(matchSetInd:matchSetInd,match:match,scores:scores)
}

