//
//  ResultModel.swift
//  goodMatches
//
//  Created by Yo Sato on 21/05/2024.
//

import Foundation

func get_elo_prob(favourite:Team, against:Team, n:Double=400.0)-> Double{
    let scoreDiff=Double(against.meanScore-favourite.meanScore)
    let divisor=1.0+pow(10.0,scoreDiff/n)
    return Double(1.0/divisor)
}

func get_elo_update_value(winningTeam:Team, against:Team, result:(Int,Int), k:Int=8)-> Double{
    let resultRate=Double(result.0/(result.0+result.1))
    let expectedProb=get_elo_prob(favourite:winningTeam,against:against)
    return Double(k)*expectedProb*resultRate
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

struct MatchSetResult{
    let sizedCourtCounts:[Int:Int]
    var matchResults=[MatchResult]()
   //  assert(matchResults.map{matchResult in matchResult.matchSetInd})
    var matchSetInd:Int? {!matchResults.isEmpty ? matchResults[0].matchSetInd : nil}
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
    var scores:(Int,Int)
    var id:String {match.id+"__"+String(matchSetInd)}
    var drawnP:Bool {scores.0==scores.1}
}

func get_matchresult(matchSetInd:Int,match:Match,scores:(Int,Int))-> MatchResult{
    return MatchResult(matchSetInd:matchSetInd,match:match,scores:scores)
}

