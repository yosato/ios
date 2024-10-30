//
//  ResultModelswift
//  goodMatches
//
//  Created by Yo Sato on 21/05/2024.
//

import Foundation

func get_elo_prob(favourite:Team, against:Team, n:Double=50.0)-> Double{
    let scoreDiff=Double(favourite.meanScore-against.meanScore)
    let divisor=1.0+pow(10.0,scoreDiff/n)
    return Double(1.0/divisor)
}

func get_elo_update_value(winningTeam:Team, against:Team, result:(Int,Int), k:Int=3)-> Double {
    assert(result.0>=result.1)
    if result.0==result.1 {return 0.0}
    let resultRate=0.1*Double(result.0-result.1)+0.7
    let weight=(winningTeam.players.count==4 ? 0.8 : 0.6)
    let expectedProb=get_elo_prob(favourite:winningTeam,against:against)
    
    
    let meanDiffToBound=diffToBound(score:winningTeam.meanScore).0 != diffToBound(score:against.meanScore).0 ? 50 : (diffToBound(score:winningTeam.meanScore).1+diffToBound(score:against.meanScore).1 )/2.0
    let coeffWeight=(0.9*meanDiffToBound+4.1)/50.0
    return Double(k)*expectedProb*resultRate*coeffWeight
    
    func diffToBound(score:Double)->(Bool,Double){
        return (score>50.0 ? (false, 100.0-score) : (true, score-0.0))
    }

}

class MatchSetHistory:ObservableObject{
    @Published var results=[MatchSetResult]()
    var lastCompleted:Bool? {!self.results.isEmpty ? self.results.last!.completed : nil}
    
    func get_first_matchResult_byMatchID(_ matchID:String)-> MatchResult?{
        for matchSetResult in self.results{
            for matchResult in matchSetResult.matchResults{
                if matchResult.id==matchID{
                    return matchResult
                }
            }
        }
        return nil
    }
    
    func add_replace_matchSetResult(_ matchSetResult:MatchSetResult, sizedCourtCounts:[Int:Int]){
        // if the MSR does not exist already add it, if it does replace it
        if let hitInd=results.firstIndex(where:{$0.matchSetInd==matchSetResult.matchSetInd}){
            // case of replacing
            self.results[hitInd]=matchSetResult
        }else{
            // case of adding
            self.results=[matchSetResult]+self.results
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
    var matchResults=[MatchResult]()
   //  assert(matchResults.map{matchResult in matchResult.matchSetInd})
    var sizedCourtCounts:[Int:Int] {
        var sizedCourtCounts=[Int:Int]()
        for matchResult in matchResults{
            sizedCourtCounts[matchResult.matchSize,default:0]+=1
        }
        return sizedCourtCounts
    }
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
    var matchSize:Int {match.teamsize*2}
    // match result id is the combo of match id (who plays against whom) and match set ind
    var id:String {match.id+"__"+String(matchSetInd)}
    var drawnP:Bool {scores.0==scores.1}
    var winningInd:Int? {drawnP ? nil : (scores.0>scores.1 ? 0 : 1)}
    
    func prettystring()->String{
        let team0Str=match.teams.0.playersString
        let team1Str=match.teams.1.playersString
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

