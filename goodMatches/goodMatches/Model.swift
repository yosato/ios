//
//  Model.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import Foundation


enum Gender:String{
    case male="male"
    case female="female"
}

class Player: Codable, Equatable, Hashable, Identifiable{
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id==rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

    enum CodingKeys:String,CodingKey{
        case name
        case score
        case gender
        case club
        //case id

    }
    var name: String
    var score: Double
    var gender: String
    var club:String
    var nameLen:Int {name.split(separator:" ").count}
    var nameAbbr:String {name.split(separator:" ")[0].lowercased()+(nameLen>1 ? name.split(separator:" ")[1].capitalized : "")}
    var clubAbbr:String {club.split(separator: " ").map{word in word.prefix(1)}.joined(separator:"")}
    var id:String {nameAbbr+"_"+clubAbbr}
    var preferencesIntraMS:[(Player,MatchSetOnCourt)->Bool]=[]
    var preferencesInterMS:[(Player,MatchSetOnCourt,MatchSetOnCourt)->Bool]=[]

    init(name:String,score:Double,gender:String,club:String){
        self.name=name; self.score=score; self.gender=gender; self.club=club
    }
    
    func update_score(_ increment: Double){
        self.score+=increment
    }
}

struct PlayerSet:Hashable,Equatable,Identifiable {
    static func == (lhs: PlayerSet, rhs: PlayerSet) -> Bool {
        lhs.id==rhs.id
    }
    let players:[Player]
    let id:String
    
    init(_ players:[Player]){
        self.players=players.sorted{$0.name<$1.name}
        self.id=self.players.map{player in player.id}.joined(separator: "--")
    }
    init(_ players:Set<Player>){
        self.players=players.sorted{$0.name<$1.name}
        self.id=self.players.map{player in player.id}.joined(separator: "--")
    }
}
struct Team:Hashable,Equatable,Identifiable {
    var players:[Player]
    var id:String
    var playersString:String {players.map{player in player.name}.joined(separator: " / ")}
    var playerSet:Set<Player> {Set(self.players)}
    var scores:[Double] {players.map{$0.score}}
    var totalScore:Double {sum(scores)}
    var meanScore:Double {self.totalScore/Double(self.players.count)}
    init(_ players:[Player]){
        self.players=players.sorted{$0.name>$1.name}
        self.id=players.map{player in player.id}.joined(separator: "/")
    }
    init(_ players:Set<Player>){
        self.players=players.sorted{$0.name>$1.name}
        self.id=players.map{player in player.id}.joined(separator: "/")
    }
    mutating func update_playerscores(_ playersScores:[Player:Double]){
        for (playerToUpdate,newScore) in playersScores{
            if let index=players.firstIndex(where:{$0.id==playerToUpdate.id}){
                players[index].score=newScore
            }
        }
    }
    func updated_playerscores(_ players:[Player])->Team{
        var myTeam:Team=self
        for playerToUpdate in players{
            if let index=myTeam.players.firstIndex(where:{playerToUpdate.id==$0.id}){
                myTeam.players[index].score=playerToUpdate.score
            }
        }
        return myTeam
    }
    func updated_playerscore(player:Player)->Team{
        var myTeam:Team=self
        if let index=players.firstIndex(where:{player.id==$0.id}){
            myTeam.players[index].score=player.score
            }
        return myTeam
    }
}

class Match:Identifiable, Equatable, Hashable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.teams==rhs.teams
    }
    
    var teams:(Team,Team)
    let id:String
    
    func hash(into hasher: inout Hasher){
        hasher.combine([teams.0,teams.1])
    }
        //    var playerSets:([Player],[Player]) { (self.teams.0.players, self.teams.1.players) }
    var pairOfPlayers:([Player],[Player]) { (self.teams.0.players, self.teams.1.players) }
    //var players:[Player] { playerSets.0+playerSets.1 }
    var listOfPlayers:[Player] { pairOfPlayers.0+pairOfPlayers.1.sorted{$0.score>$1.score} }
    var teamsize:Int { pairOfPlayers.0.count }
    var playerStringSets:([String],[String]) {(self.pairOfPlayers.0.map{$0.name},self.pairOfPlayers.1.map{$0.name})}
    var scoreDiff:Double {(teams.0.totalScore-teams.1.totalScore)/(teamsize==4 ? 2 : 1)}
    init(_ teams:[Team]) {
        let teamA=teams[0]; let teamB=teams[1]
        let team1:Team;let team2:Team
        if(teamA.totalScore>teamB.totalScore){team1=teamA;team2=teamB}else{
            team1=teamB;team2=teamA
        }
        self.teams=(team1,team2)
        self.id=[teamA.id,teamB.id].sorted{$0<$1}.joined(separator:":")
    }
    
    func update_playerscores(players:[Player]){
        var newTeams:[Team]=[]
        for team in [teams.0,teams.1]{
            newTeams.append(team.updated_playerscores(players))
            }
        teams=newTeams[0].totalScore>newTeams[1].totalScore ?(newTeams[0],newTeams[1]):(newTeams[1],newTeams[0])
    }
    
    func updated_playerscore(player:Player)-> Match{
            var newMatch=self
        var newTeams:[Team]=[]
        for team in [teams.0,teams.1]{
            newTeams.append(team.updated_playerscore(player:player))
            }
        teams=newTeams[0].totalScore>newTeams[1].totalScore ?(newTeams[0],newTeams[1]):(newTeams[1],newTeams[0])
        newMatch.teams=teams
   
        return newMatch
    }
    
}

enum Strength:String{
   case Strong="strong"
    case Weak="weak"
    case Medium="medium"
}

//@MainActor
class PlayersOnCourt:ObservableObject{
    @Published var players:[Player]=[]
    var sortedPlayers:[Player] {players.sorted(by:{$0.score>$1.score})}
    var sortedScores:[Double] {sortedPlayers.map{$0.score}}
    var maxScore:Double {sortedScores.max() ?? 100}
    var minScore:Double {sortedScores.min() ?? 0}
    var mean:Double {sum(sortedScores)/Double(sortedScores.count)}
    var stddev:Double {goodMatches.stddev(nums:sortedScores.map{Double($0)},mean:mean)}
    var thresholds:(Double,Double) {(self.mean+self.stddev,self.mean-self.stddev)}
    //var sizedStrengthClassifiedTeams:[Int:[Strength:[Team]]]=[:]
    
    func get_balanced_unbalanced_matches_perCourt(matchSizes:[Int]=[2,4],coeff:Double=1.4)-> [Int:[PlayerSet:([Match],[Match])]]{
            var sizedPlayerSetKeyedMatches=[Int:[PlayerSet:([Match],[Match])]]()
            for matchSize in matchSizes{
                var chosenCount=0
                var totalCount:Int=0
                var playerSetKeyedMatches=[PlayerSet:([Match],[Match])]()
                for (cntr,playersPerMatch) in combos(elements:self.sortedPlayers,k:matchSize).enumerated(){
                    let mergedPlayerSet=PlayerSet(playersPerMatch)
                    playerSetKeyedMatches[mergedPlayerSet]=([],[])
                    var matches=[Match]()
                    let teamSize=matchSize/2
                    let partitionsWithRemainder=get_partitions_withIntegers(Set(playersPerMatch),Array(repeating:teamSize, count:2),doPotentiallyRandomPrune: false)
                    for (partCntr,(partition,remainder)) in partitionsWithRemainder.enumerated(){
                        assert(partition.count==2)
                        let players=Array(partition)
                        let team1=Team(players[0]); let team2=Team(Array(players[1]));let match=Match([team1,team2])
                        if(abs(team1.meanScore-team2.meanScore)<self.stddev*(coeff/Double(teamSize))){
                            playerSetKeyedMatches[mergedPlayerSet]!.0.append(match)
                            chosenCount+=1}else{playerSetKeyedMatches[mergedPlayerSet]!.0.append(match)}
                        totalCount+=1
                    }
                }
                print("\(chosenCount) chosen out of \(totalCount) for matchsize \(matchSize) ")
                sizedPlayerSetKeyedMatches[matchSize]=playerSetKeyedMatches
            }
            return sizedPlayerSetKeyedMatches
            
        }

    func get_sized_strengthClassified_teams(matchSizes:[Int]=[2,4])->[Int:[Strength:[Team]]]{
        var sizedStrengthClassifiedTeams:[Int:[Strength:[Team]]]=[2:[Strength.Strong:[],Strength.Medium:[],Strength.Weak:[]],4:[Strength.Strong:[],Strength.Medium:[],Strength.Weak:[]]]
        for n in matchSizes{
            for playerSet in goodMatches.combos(elements:self.sortedPlayers,k:n/2){
                if (playerSet.count==2 && playerSet[0]==playerSet[1]){continue}
                let aTeam=Team(playerSet)
                let strength:Strength
                if(aTeam.meanScore<self.thresholds.0){
                    strength=Strength.Weak
                }else if(aTeam.meanScore>self.thresholds.1){
                    strength=Strength.Strong}
                    else{strength=Strength.Medium}
                sizedStrengthClassifiedTeams[n]![strength]!.append(aTeam)
            }}
        return sizedStrengthClassifiedTeams
    
    }
    //    init(_ players:[Player]){
    //      self.players=players
    //}
    func get_relativestrength_team(_ team:Team)-> String{
        let meanScore=sum(team.scores.map{Double($0)})/Double(team.players.count)
        let upperThresh=self.thresholds.0
        let lowerThresh=self.thresholds.1
        if(meanScore>=upperThresh){return "s"}else if(meanScore<=lowerThresh){return "w"}else{return "m"}
    }
    func delete_all_players(){
        self.players=[]
    }
    func add_player(_ player:Player){
        if !self.players.contains(player)
        {self.players=[player]+self.players}
    }
    func add_players(_ players:[Player]){
        for player in players{
            self.add_player(player)
        }
        
    }
    
    func update_playerscores_matchResult(_ result:MatchResult)->((Team,Team),Double)?{
        if(result.drawnP){
            return nil
        }
        
        let winningTeam=(result.scores.0>result.scores.1 ? result.match.teams.0 : result.match.teams.1)
        let losingTeam=(result.scores.0>result.scores.1 ? result.match.teams.1 : result.match.teams.0)
        let scores=(result.scores.0>result.scores.1 ? result.scores : (result.scores.1,result.scores.0))
        
        let increment=round(1000.0*get_elo_update_value(winningTeam:winningTeam,against:losingTeam,result:scores))/1000.0
            
        for winningPlayer in winningTeam.players{
            let ind=playerInd_fromID(winningPlayer.id)
            self.players[ind].score+=increment
        }
        for losingPlayer in losingTeam.players{
            let ind=playerInd_fromID(losingPlayer.id)
            self.players[ind].score-=increment
        }
        return ((winningTeam,losingTeam),increment)
    }

    func update_playerscores_matchSetResult(_ matchSetResult:MatchSetResult)->[((Team,Team),Double)]{
        var gainsLosses:[((Team,Team),Double)]=[]
        for matchResult in matchSetResult.matchResults{
            let gainLoss=self.update_playerscores_matchResult(matchResult)
            if(gainLoss != nil){
                gainsLosses.append(gainLoss!)
            }
            
        }
        return gainsLosses
    }
    func update_playerscores_matchResults(_ matchResults:MatchSetHistory){
        for matchSetResult in matchResults.results{
            self.update_playerscores_matchSetResult(matchSetResult)
        }
    }

    func update_playerscores_remote(urlStr:String) async {
        for player in self.players{
            if let request=get_url_request(urlStr: urlStr, requestType: "PUT"){
                guard let encodedPlayer=try? JSONEncoder().encode(player) else{return}
                do{let (data, _) = try await URLSession.shared.upload(for:request,from:encodedPlayer)}catch{print()}
            }
        }
    }
    
    func playerInd_fromID(_ id:String)-> Int{
        for (ind,player) in self.players.enumerated(){
            if player.id==id{
                return ind
            }
        }
        return -1
    }
}


// set of matches played simultaneously, size classified, size=2 or 4, plus resting players
struct MatchSetOnCourt:Hashable,Equatable{
    static func == (lhs: MatchSetOnCourt, rhs: MatchSetOnCourt) -> Bool {
        Set(lhs.matchesOnCourt)==Set(rhs.matchesOnCourt)
    }
    
    var sizedMatchesOnCourt:[Int:[Match]]
    let sizedCourtCounts:[Int:Int]
//    let myPlayers:PlayersOnCourt
    let restingPlayerSet:PlayerSet
    var finished:Bool
    
    var doublesOnlyP:Bool {sizedCourtCounts.keys.count==1 && sizedCourtCounts.keys.contains(4)}
    var singlesOnlyP:Bool {sizedCourtCounts.keys.count==1 && sizedCourtCounts.keys.contains(2)}
    var mixedP:Bool {!singlesOnlyP && !doublesOnlyP}
    var sizedWeights:[Int:Double] {mixedP ? [2:0.3,4:0.7] : (doublesOnlyP ? [4:1.0] : [2:1.0])}
    
    var matchesOnCourt:[Match] {(sizedMatchesOnCourt[4] ?? [])+(sizedMatchesOnCourt[2] ?? [])}

    var playingPlayers:[Player]  {matchesOnCourt.map{match in match.listOfPlayers}.flatMap{$0}}
    var allPlayers:[Player]  {playingPlayers+restingPlayerSet.players}
    
    var allTeamOppositions:[(Team,Team)] {matchesOnCourt.map{$0.teams}}
    var playingRestingPlayerCounts:(Int,Int) {(self.playingPlayers.count, self.restingPlayerSet.players.count)}
    
    func hash(into hasher: inout Hasher){
        hasher.combine([sizedMatchesOnCourt])
    }
    
    func pretty_print(){
        for matchSize in self.sizedMatchesOnCourt.keys.sorted(){
            print("\(matchSize): "+self.sizedMatchesOnCourt[matchSize]!.map{ms in ms.id}.joined(separator: "---"))
            print("resting: \(self.restingPlayerSet.id)")
            print("total diff \(self.totalScoreDiff)")
        }
    }
    
    //    mutating func update_playerscores(_ playersScores:[Player:Double]){
    //        for player in allPlayers{
    //            for (_size,matches) in sizedMatchesOnCourt{
    //                for match in matches{
    //                    match.update_playerscores(playersScores: playersScores)
    //                }
    //            }
    //        }
    //
    //    }
    
//    func updated_playerscores()->MatchSetOnCourt{
//        var myMatches:[Match]=[]
//        for match in matchesOnCourt{
//            match.update_playerscores(players: myPlayers.players)
//            myMatches.append(match)
//        }
//        
//        return MatchSetOnCourt(myMatches,myPlayers:self.myPlayers,restingPlayers:restingPlayers)
//        
//    }

    var sizedScoreDiffs:[Int:Double] {
        let myTuple=self.sizedMatchesOnCourt.map { (size,matches) in
            return (size, Double(matches.map{match in match.scoreDiff}.reduce(0,+))/Double(sizedMatchesOnCourt[size]!.count))
        }
        return Dictionary(uniqueKeysWithValues: myTuple)
    }
//    var sizedWeights:[Int:Double] {
//        return intDict2weightDict(sizedCourtCounts)
//    }
    var totalScoreDiff:Double {
        let sizedScoreDiffsT=sizedMatchesOnCourt.map{ (size,matches) in (size, matches.map{ match in Double(match.scoreDiff) } )  }
        let sizedTotalScoreT=sizedScoreDiffsT.map{ (size,scoreDiffs) in (size, scoreDiffs.reduce(0,+)/Double(sizedCourtCounts[size]!)) }
        var cum=0.0
        for (size,cumScore) in sizedTotalScoreT{
            cum+=cumScore*sizedWeights[size]!
        }
        return cum
    }
    
    init(_ sizedMatches:[Int:[Match]], sizedCourtCounts:[Int:Int], restingPlayerSet:PlayerSet){
        self.sizedMatchesOnCourt=sizedMatches
        self.restingPlayerSet=restingPlayerSet
        self.sizedCourtCounts=sizedCourtCounts
        self.finished=false
        //self.myPlayers=myPlayers
    }
    init(_ matches:[Match], restingPlayerSet:PlayerSet){
        var sizedMatches=[Int:[Match]](); var sizedCC=[Int:Int]()
        self.finished=false
        for match in matches{
            let playerCount=match.listOfPlayers.count
            if let _=sizedMatches[playerCount]{sizedMatches[playerCount]!.append(match)}else{sizedMatches[playerCount]=[match]}
            if let _=sizedCC[playerCount]{sizedCC[playerCount]!+=1}else{sizedCC[playerCount]=1}
            
        }
                    
        self.sizedMatchesOnCourt=sizedMatches
        self.restingPlayerSet=restingPlayerSet
        self.sizedCourtCounts=sizedCC
        //self.myPlayers=myPlayers
        
    }
    func match_identical(_ anotherMatchSet:MatchSetOnCourt)->Bool{
        let matches1=self.matchesOnCourt
        let matches2=anotherMatchSet.matchesOnCourt
        if matches1.count != matches2.count{
            return false
        }
        for match1 in matches1{
            if !matches2.contains(match1){
                return false
            }
        }
        return true
    }
    func singlesPlayerShare_rate(_ anotherMatchSet:MatchSetOnCourt)->Double?{
        return goodMatches.singlesPlayerShare_rate(self,anotherMatchSet)
    }
    
    func doublesTeamShare_rate(_ anotherMatchSet:MatchSetOnCourt)->Double?{
        return goodMatches.doublesTeamShare_rate(self, anotherMatchSet)
    }
}

func singlesPlayerShare_rate(_ aMatchSet:MatchSetOnCourt,_ anotherMatchSet:MatchSetOnCourt)->Double?{
    assert(aMatchSet.sizedCourtCounts==anotherMatchSet.sizedCourtCounts)
    if (!aMatchSet.sizedCourtCounts.keys.contains(2)){return nil}
    let matches1=aMatchSet.sizedMatchesOnCourt[2]!
    let matches2=anotherMatchSet.sizedMatchesOnCourt[2]!
    let players1=Set(matches1.map{$0.listOfPlayers}.flatMap{$0})
    let players2=Set(matches2.map{$0.listOfPlayers}.flatMap{$0})
    let playerCount=players1.count
    let sharedPlayers=players1.intersection(players2)
    return Double(sharedPlayers.count)/Double(playerCount)

}

func shared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt, shareRateFnc:(MatchSetOnCourt,MatchSetOnCourt)->Double?)->Bool{
    assert(aMatchSet.sizedCourtCounts==anotherMatchSet.sizedCourtCounts)
    return shareRateFnc(aMatchSet, anotherMatchSet) != 0
}

//func singlesPlayerShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
//    assert(aMatchSet.sizedCourtCounts.keys.contains(2))
//    return shared_p(aMatchSet,anotherMatchSet,shareRateFnc:singlesPlayerShare_rate)
//}
func singlesPlayerNotShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert(aMatchSet.sizedCourtCounts.keys.contains(2))
    return !shared_p(aMatchSet,anotherMatchSet,shareRateFnc:singlesPlayerShare_rate)
}

func doublesTeamShare_rate(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Double?{
    assert(aMatchSet.sizedCourtCounts==anotherMatchSet.sizedCourtCounts)
    if (!aMatchSet.sizedCourtCounts.keys.contains(4)){return nil}
    let matches1=aMatchSet.sizedMatchesOnCourt[4]!
    let matches2=anotherMatchSet.sizedMatchesOnCourt[4]!
    let teams1=Set(matches1.map{[$0.teams.0,$0.teams.1]}.flatMap{$0})
    let teams2=Set(matches2.map{[$0.teams.0,$0.teams.1]}.flatMap{$0})
    assert(teams1.count==teams2.count)
    let teamCount=teams1.count
    let sharedTeams=teams1.intersection(teams2)
    return Double(sharedTeams.count)/Double(teamCount)
}

func doublesTeamShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert (aMatchSet.sizedCourtCounts.keys.contains(4))
    return shared_p(aMatchSet, anotherMatchSet, shareRateFnc:doublesTeamShare_rate)
    
}
func doublesTeamNotShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert (aMatchSet.sizedCourtCounts.keys.contains(4))
    return !shared_p(aMatchSet, anotherMatchSet, shareRateFnc:doublesTeamShare_rate)
    
}

func matchset_duplicate_p(_ matchSets:[MatchSetOnCourt], doProportion:Double=1.0)->Bool{
    let matchCount=matchSets.count
    for (idx,currentMS) in matchSets.enumerated(){
        if(idx != 0 && idx%200==0){
            let doneProp=Double(idx)/Double(matchCount)
            print("\(idx) MSs out of \(matchCount) (\(doneProp)) checked")
            if(doProportion < 1.0 && doneProp>doProportion){return false}}
        for anotherMS in matchSets[0..<idx]+matchSets[idx+1..<matchCount]{
            if currentMS.match_identical(anotherMS){
                print("duplicate at \(idx)")
                return true
            }
        }
    }
    return false
}

func assign_courtTeamsize(courtCount:Int,playerCount:Int)-> [Int:Int]{
//    let maxPlayers=courtCount*4
    assert(courtCount>=1 && playerCount>=2)
    var count4:Int = courtCount
    var count2:Int = 0
    var playingPlayerCount=courtCount*4
    while(true){
        if (playerCount-playingPlayerCount>=2){break}
        if (playingPlayerCount <= playerCount && playerCount - playingPlayerCount <= 1){
            break
        }
        count4-=1
        count2=courtCount-count4
        playingPlayerCount=count4*4+count2*2
    }
    assert(count4+count2==courtCount)
    return [4:count4, 2:count2].filter{(_k,v) in v != 0}
}

class RestingPlayerKeyedMatchSetsOnCourt{
    var restingPlayerKeyedMatchSets:[PlayerSet:([MatchSetOnCourt],[MatchSetOnCourt])]
    var partitionBasedRestingPlayerSetList:[PlayerSet]
    
    var shortestCount:Int {restingPlayerKeyedMatchSets.values.map{ms in ms.0.count}.min()!}
    
    var nextUnfinishedRPSet:PlayerSet? {
        let restingPlayerFinishedCounts=restingPlayerKeyedMatchSets.mapValues{(_unfinishedMSs,finishedMSs) in (finishedMSs.count) }
        let lessFinishedCount:Int=Array(restingPlayerFinishedCounts.values).min()!
        for playerSet in partitionBasedRestingPlayerSetList{
            if(restingPlayerFinishedCounts[playerSet]==lessFinishedCount){return playerSet}
        }
        return nil
    }
    var nextUnfinishedRPKeyedMSs:[MatchSetOnCourt] {nextUnfinishedRPSet==nil ? [] : restingPlayerKeyedMatchSets[nextUnfinishedRPSet!]!.0}
    var chosenForwardInd:Int?=nil
    
    init(_ restingPlayerKeyedMatchSetsOnCourt: [PlayerSet : ([MatchSetOnCourt],[MatchSetOnCourt])]) {
        assert(!restingPlayerKeyedMatchSetsOnCourt.isEmpty)
        let restingPlayerCounts=restingPlayerKeyedMatchSetsOnCourt.keys.map{pSet in pSet.players.count}
        assert(all_identical(restingPlayerCounts))
        let restingPlayerCount=restingPlayerCounts[0]
        self.restingPlayerKeyedMatchSets = restingPlayerKeyedMatchSetsOnCourt
        let allPlayers:Set<Player>=restingPlayerKeyedMatchSetsOnCourt.keys.map{playerSet in Set(playerSet.players)}.reduce(Set()){$0.union($1)}
        
        let playingPlayerCounts=allPlayers.count-restingPlayerCount
        self.partitionBasedRestingPlayerSetList=(restingPlayerCount==0 ? [PlayerSet([])] : partition_based_ordering(Array(allPlayers), Array(repeating:restingPlayerCount, count:allPlayers.count/restingPlayerCount)).map{players in PlayerSet(players)})

    }
    func update_onResult()->Bool?{
        guard let currentPSet=nextUnfinishedRPSet else {return nil}
        guard var foundMSSets=restingPlayerKeyedMatchSets[currentPSet] else {return nil}
        guard let chosenForwardInd=self.chosenForwardInd else {return nil}
        foundMSSets.1.append(foundMSSets.0.remove(at:self.chosenForwardInd!))
        self.restingPlayerKeyedMatchSets[currentPSet]=foundMSSets
        let changed=order_matchsets()
        return changed
    }
    
    func transfer_unfinished_to_finished(anInd:Int){
        
    }
    
    func order_matchsets()->Bool{
        var changed:Bool=false
        for (pSet,MSs) in restingPlayerKeyedMatchSets{
            let old=restingPlayerKeyedMatchSets[pSet]!.0
            let new=restingPlayerKeyedMatchSets[pSet]!.0.sorted{$0.totalScoreDiff<$1.totalScoreDiff}
            if(old != new){
                changed=true
            }
            restingPlayerKeyedMatchSets[pSet]!.0=new
        }
      return changed
    }
    
}


class GoodMatchSetsOnCourt:ObservableObject{
    // the tip is current, otherwise finished MSs
    @Published var orderedMatchSets:[MatchSetOnCourt]=[]
    @Published var courtCount:Int?=nil
//    var restPlayerKeyedOrderedMatchSets:[PlayerSet:[MatchSetOnCourt]
    let lookForwardProportion=0.5
    let pruneQuotient=20


    // these properties become available with the main function, get_best_matches
    var restingPlayerKeyedMatchSets:RestingPlayerKeyedMatchSetsOnCourt? = nil

    var matchSetMaxCountToProduce:Int? = nil
    var interMatchSetConstraintFncs=[(MatchSetOnCourt,MatchSetOnCourt)->Bool]()
//    var constraintTipWindow:(Int,Int)? = nil
    var lookBackDepth:Int? = nil
    var lookForwardExtent:Int? = nil
    var matchSetCountPerRestingPlayer:Int?=nil
    var playingRestingPlayerCounts:(Int,Int)? = nil
    var allPlayers:[Player]? = nil
    var sizedCourtCount:[Int:Int]? = nil
    var frequentResterIDs:Set<String> = Set(["noriko_MWL"])
    var doublesSinglesPs:(Bool,Bool)? {self.sizedCourtCount==nil ? nil : (self.sizedCourtCount!.keys.contains(4),self.sizedCourtCount!.keys.contains(2))}
    var restingExists:Bool? {playingRestingPlayerCounts == nil ? nil : playingRestingPlayerCounts!.1 != 0 }
    var orderedRPSets:[PlayerSet]? = nil
    
    func all_share_players()->Bool{
        return true
    }


    // THIS IS THE MAIN FUNC!
    func get_best_new_matchset(_ playersOnCourt:PlayersOnCourt, _ courtCount:Int){
        //setting basic vars
        self.sizedCourtCount=assign_courtTeamsize(courtCount: courtCount, playerCount: playersOnCourt.players.count)
        self.courtCount=sizedCourtCount!.values.reduce(0,+)
        let playingPlayerCount:Int=self.sizedCourtCount!.map{(size,count) in size*count}.reduce(0,+)
        self.allPlayers=playersOnCourt.players
        self.playingRestingPlayerCounts=(playingPlayerCount,self.allPlayers!.count-playingPlayerCount)
        if(self.sizedCourtCount!.keys.contains(2)){self.interMatchSetConstraintFncs.append(singlesPlayerNotShared_p)}
        if(self.sizedCourtCount!.keys.contains(4)){self.interMatchSetConstraintFncs.append(doublesTeamNotShared_p)}
        
        let startTime=Date()
        print(Date())
        print("initial matchsets...")
        let sizePlayerKeyedMatches=playersOnCourt.get_balanced_unbalanced_matches_perCourt(matchSizes:Array(self.sizedCourtCount!.keys))

        // get all matchsets, resting-player classified
        print("getting possible combinations per rest players...")
        self.restingPlayerKeyedMatchSets=self.get_good_matchsets(self.sizedCourtCount!, sizePlayerKeyedMatches, playersOnCourt)
        print("... combinations done")
        // ordering
        print("ordering matchsets per RP...")
        let _=self.restingPlayerKeyedMatchSets!.order_matchsets()

        let shortestCnt:Int=restingPlayerKeyedMatchSets!.shortestCount
//        self.restPlayerKeyedOrderedMatchSets=RPKeyedMSs.mapValues{val in Array(val[0..<shortestCnt-1])}
        
        if(shortestCnt<100){self.lookBackDepth=3;self.matchSetMaxCountToProduce=6}else if(shortestCnt<500){self.lookBackDepth=4;self.matchSetMaxCountToProduce=10}else{self.lookBackDepth=4;self.matchSetMaxCountToProduce=15}
        self.lookForwardExtent=max(shortestCnt-1,Int(self.lookForwardProportion*Double(shortestCnt)))
        print("getting next constraint-satisfying matchset...")
        guard let (nextMatchSet,matchSetInd)=self.get_next_constrained_matchset() else {print("failed to find a MS");return}
        if(self.orderedMatchSets==nil){ self.orderedMatchSets=[nextMatchSet] }else{self.orderedMatchSets.append(nextMatchSet)
            // assert(!matchset_duplicate_p(orderedGoodMatchSets))
            print("All done")
            let endTime=Date()
            let timeElapsed=endTime.timeIntervalSince(startTime)
            print(endTime)
            print(timeElapsed)
            //        let finalMatchSets=apply_intermatchset_constraints(orderedGoodMatchSets,firstPart:6)
            
            //        self.orderedMatchSets=finalMatchSets
         //   self.courtCount=courtCount
            
        }
    }
        
        // all the heavy lifting
        func get_good_matchsets(_ sizedCourtCounts:[Int:Int], _ sizePlayerKeyedMatches:[Int:[PlayerSet:([Match],[Match])]], _ playersOnCourt:PlayersOnCourt, debug:Bool=false)-> RestingPlayerKeyedMatchSetsOnCourt{
            
            func construct_matchsetsOnCourt_from_partition(_ playerPartition:Set<Set<Player>>, restingPlayerSet:PlayerSet, potentialMatches:[Int:[PlayerSet:([Match],[Match])]],debug:Bool=false)->[MatchSetOnCourt]{
                // e.g. a partition could be <a,b>, <c,d,e,f>, <g,h,i,j>
                // then the max matchgroups will be < match(a/b) >, < match(cd/ef), match(ce/df), match(cf/de) >, < match(gh/ij), match(gi/hj), match(gj/hi) >
                
                var matchGroups=[[Match]]()
                for playersPerCourt in playerPartition{
                    //var matchesPerGroup=[Match]()
                    let size=playersPerCourt.count
                    let playerSet=PlayerSet(playersPerCourt)
                    let matchesPerCourt:[Match]
                    // for singles, only 1, for doubles, up to 3
                    if(potentialMatches[size]![playerSet]!.0.isEmpty ){
                        if(debug){print("\(playersPerCourt.map{player in player.id}) not in balanced match data")}
                        matchesPerCourt=potentialMatches[size]![playerSet]!.1}else{matchesPerCourt=potentialMatches[size]![playerSet]!.0}
                    assert(!matchesPerCourt.isEmpty)
                    //                matchesPerGroup+=
                    matchGroups.append(matchesPerCourt)
                }
                assert(!matchGroups.isEmpty)
                assert(matchGroups.count==playerPartition.count)
                return generalised_product(matchGroups).map{matchSet in MatchSetOnCourt(matchSet, restingPlayerSet: restingPlayerSet)}
            }
            
            // to be returned, a matchSetOnCourt is a set of player-exclusive matches happening at a time on multiple courts
            // flat list of matchSetOnCourts will be returned, with the concurrent match count length
            var restingPlayerKeyedMatchSetsOnCourt=[PlayerSet:([MatchSetOnCourt],[MatchSetOnCourt])]()
            // e.g. for 12 people with 4 courts, we'll have 2singlesx2 + 2doublesx4 = 12. Each element, i.e. a matchSetCourt, will consist of four matches, 2 singles, 2 doubles
            
            var ints=[Int]()
            for (size,count) in sizedCourtCounts{
                ints+=Array(repeating:size,count:count)
            }
            var sizedPlayerSetsToExclude=[Int:Set<Set<Player>>]()
            var sizedPlayerSetsToInclude=[Int:Set<Set<Player>>]()
            //var sizedPlayerSetsToAdd=[Int:Set<Set<Player>>]()
            for (size,playerKeyedMatches) in sizePlayerKeyedMatches{
                for (playerSet,matches) in playerKeyedMatches{
                    if(matches.0.isEmpty){
                        sizedPlayerSetsToExclude[size, default:Set<Set<Player>>()].insert(Set(playerSet.players))
                    }else{
                        sizedPlayerSetsToInclude[size, default:Set<Set<Player>>()].insert(Set(playerSet.players))
                    }
                }
            }
            
            let playerSet=Set(playersOnCourt.players)
            let doRandomPrune:Bool=playerSet.count*self.courtCount! > 32
            
            print("generating partitions, "+(!doRandomPrune ? "exhaustively" : "with pruning"))
            
            let playingPlayerPartitionsWithRemainder=(!doRandomPrune ? get_partitions_withIntegers(playerSet, ints, sizedSetsToExclude:sizedPlayerSetsToExclude, doPotentiallyRandomPrune:true, debug:true) : generate_distinct_paritions_withIntegers_withRemainderHoldout_withSizedSets(playerSet, ints: ints, sizedSets:sizedPlayerSetsToInclude))
            let remCombos=Set(playingPlayerPartitionsWithRemainder.map{(_partition,rem) in rem})
            
            print("creating RP key-based MSs...")
            var RPKeyedPartitionSets=[PlayerSet:Set<Set<Set<Player>>>]()
            for (playingPlayerPartition,restingPlayers) in playingPlayerPartitionsWithRemainder{
                assert(!playingPlayerPartition.isEmpty)
                assert(Set(playingPlayerPartition.flatMap{$0}).intersection(restingPlayers).isEmpty)
                RPKeyedPartitionSets[PlayerSet(restingPlayers),default: Set<Set<Set<Player>>>()].insert(playingPlayerPartition)
            }
            
            assert(RPKeyedPartitionSets.keys.count==combo_count(n:self.allPlayers!.count, k:playingRestingPlayerCounts!.1))
            
            //restingplayer-keyed MSs
            for (restingPlayerSet,playingPlayerPartitions) in RPKeyedPartitionSets{
                
                var matchSetsPerRPNotFlat=[[MatchSetOnCourt]]()
                for playingPlayerPartition in playingPlayerPartitions{
                    assert(!playingPlayerPartition.isEmpty)
                    matchSetsPerRPNotFlat.append(construct_matchsetsOnCourt_from_partition(playingPlayerPartition, restingPlayerSet:restingPlayerSet, potentialMatches:sizePlayerKeyedMatches, debug:false))
                }
                let matchSetsPerRP=Array(matchSetsPerRPNotFlat.joined())
                assert(!matchSetsPerRP.isEmpty)
                for matchSetPerRP in matchSetsPerRP{
                    assert(Set(matchSetPerRP.playingPlayers).intersection(Set(restingPlayerSet.players)).isEmpty)
                }
                restingPlayerKeyedMatchSetsOnCourt[restingPlayerSet]=(matchSetsPerRP,[])
                
            }
            //checking the completeness of the RP keys
            if(self.playingRestingPlayerCounts!.1 == 0){assert(restingPlayerKeyedMatchSetsOnCourt.keys.count==1)//no RP means a single empty key
            }else{
                assert(restingPlayerKeyedMatchSetsOnCourt.keys.count==combo_count(n:self.allPlayers!.count,k:playingRestingPlayerCounts!.1))
            }
            
            return RestingPlayerKeyedMatchSetsOnCourt(restingPlayerKeyedMatchSetsOnCourt)
            
        }//closes the good matches func
    
    func get_next_constrained_matchset()->(MatchSetOnCourt,Int)?{
        let restingPlayerSet:PlayerSet
        guard let restingPlayerSet=self.restingPlayerKeyedMatchSets!.nextUnfinishedRPSet else{print("no MSs left");return nil}
        
        var remainingForwardMSsPerRP=self.restingPlayerKeyedMatchSets!.restingPlayerKeyedMatchSets[restingPlayerSet]!.0
        print("remaining forward MS: \(remainingForwardMSsPerRP.count)")
        // only nil case, when you run out of foward MSs (should not happen)
        if(remainingForwardMSsPerRP.count==0){return nil}

        //for the first round just return the tip of the next unfinished rpkey MSs. index is therefore zero (this one is also returned later if nothing promising is found)
        let defaultMSAndInd=(self.restingPlayerKeyedMatchSets!.nextUnfinishedRPKeyedMSs[0],0)
        if(self.orderedMatchSets.isEmpty){//chosenForwardMSInd=0;foundDepth=nil;sourceConstInd=nil;fromEqui=true
            self.restingPlayerKeyedMatchSets?.chosenForwardInd=0
            return defaultMSAndInd}
                
        // from the second round onwards
        let chosenForwardMSInd:Int //this will be returned along with new MS itself
        //these are auxiliary stuff about how the MS has been chosen
        let foundDepth:Int? // depth in history
        let sourceConstInd:Int? // which constraint is satisfied
        let fromEqui:Bool // whether all constraints were satisfied
        
        //how deep you go in history depends on the depth parameter plus the history length itself
        let historyStartInd=(self.orderedMatchSets.count>self.lookBackDepth! ? self.orderedMatchSets.count-self.lookBackDepth! : 0)
        // the most recent first
        var reversedRecentHistory=Array(self.orderedMatchSets[historyStartInd...].reversed())
                var currentHistLength=reversedRecentHistory.count

        //otherwise search rp-keyed MSs for the one satisfying constraints against (a depth of) history
        print("\(self.orderedMatchSets.count) history MS(s) to be checked up to depth \(currentHistLength)")
        // what you get is the depth-ordered (reverse) list of constraint-satisfying forward MS indices per constraint in various patterns, though MS satisfying all constraints is found in depth2+, search stops
        let indsSet:[Int:[Int?]]=get_next_good_inds_over_history(remainingForwardMSsPerRP, reversedRecentHistMSs: reversedRecentHistory)
                        
        assert(indsSet.count<=currentHistLength)
        print(indsSet.sorted(by:{$0.0>$1.0}))
                        
        // pick a single forward MS with criteria: best scenario is a MS satisfying all constraints is found in the deepest history, worst no MS satisfying any constraint found at any level (foundDepth==nil)
        // intermediate cases include one is found at a shallower (recent) depth, or only partly satisfying MS is found
        let (indR,indOfIndR,constIndR,fromEquiR)=pick_ind_from_indsSet(indsSet,constWeights:(self.interMatchSetConstraintFncs.count==2 ? [3.0,1.0] : Array(repeating:1.0, count:self.interMatchSetConstraintFncs.count)))
                    
        if let indOrNil=indR, let indOfIndOrNil=indOfIndR, let constIndOrNil=constIndR, let fromEquiOrNil=fromEquiR{
             chosenForwardMSInd=indOrNil;foundDepth=indOfIndOrNil;sourceConstInd=constIndOrNil;fromEqui=fromEquiOrNil
        }else{
            // worst case, still returning the next unfinished MS
            print("no constraint-satisfying MS found, just returning next MS")
            return defaultMSAndInd}
        
        
        // should be typical of cases after 2nd round, an MS returning
        self.restingPlayerKeyedMatchSets!.chosenForwardInd=chosenForwardMSInd
        let chosenForwardMS=remainingForwardMSsPerRP[chosenForwardMSInd]
        // displaying how you got it
        print("chosen forward ind: \(chosenForwardMSInd), equi \(fromEqui)"+(!fromEqui ? " constInd \(sourceConstInd!)" : "")+" found at depth \(foundDepth!) of \(currentHistLength)")
                    if(fromEqui){
                        for (constCntr,fnc) in self.interMatchSetConstraintFncs.enumerated(){
                            for (histCntr,histMS) in Array(reversedRecentHistory[0..<foundDepth!]).enumerated(){
                                assert(fnc(chosenForwardMS,histMS))
                                       }
                        }
                    }
            
        return (chosenForwardMS,chosenForwardMSInd)

        func get_first_equiind_ind(_ indsSet:[Int:[Int?]])->(Int?,Int?){
            var foundInd:Int?=nil
            var indOfFoundIndsSet:Int?=nil
            for (depth,anIndSet) in indsSet.sorted(by: {$0.0>$1.0}){
                    if(!anIndSet.contains(nil)){
                        if(all_identical(anIndSet)){
                            return (anIndSet[0],depth)
                    }
                }
            }
            return (foundInd,indOfFoundIndsSet)
        }
        
        func pick_ind_from_indsSet(_ indsSet:[Int:[Int?]], constWeights:[Double], igoreRecentN:Int=1)->(Int?,Int?,Int?,Bool?){
            let highestDepth=indsSet.keys.max()
            var indsSet0=indsSet
            if(highestDepth! >= 3){indsSet0.removeValue(forKey: 1);print(indsSet0)}

            let (indR,indOfIndR)=get_first_equiind_ind(indsSet0)
            if let indOrNil=indR, let indOfIndOrNil=indOfIndR{
                return (indOrNil,indOfIndOrNil,0,true)
            }
            var greatestSoFar:Double?=nil
            var indSoFar:Int?=nil
            var indOfIndSoFar:Int?=nil
            var constIndSoFar:Int?=nil
            var fromEquiind:Bool?=nil
            for (cntr,anIndSet) in indsSet0.sorted(by:{$0.0>$1.0}){
                assert(constWeights.count==anIndSet.count)
                // if all is nil
                if(anIndSet.filter{el in el != nil}.isEmpty){continue}
                //here you're left with a non-equi set with at least one el non-nil
                for (constInd,ind) in anIndSet.enumerated(){
                    let candScore=(ind==nil ? 0.0 : ind_depth_metric(weightedInd:Double(ind!)*constWeights[constInd],depth:cntr+1))
                        if(greatestSoFar == nil || candScore>greatestSoFar!){
                            greatestSoFar=candScore
                            indSoFar=ind;indOfIndSoFar=cntr;constIndSoFar=constInd;fromEquiind=false
                    }
                }
            }
            return (indSoFar,indOfIndSoFar,constIndSoFar,fromEquiind)
        }
    }
    
//    func get_constrained_ordered_matchsets(from:Int=0, reorder:Bool=false)->[MatchSetOnCourt]{
//        let repetitionCount:Int=(self.playingRestingPlayerCounts!.1==0 ? 1 : self.allPlayers!.count/self.playingRestingPlayerCounts!.1)
//        let orderedParts=partition_based_ordering(self.allPlayers!, Array(repeating:playingRestingPlayerCounts!.1,count:repetitionCount))
//        if(!reorder){self.orderedRPSets=(playingRestingPlayerCounts!.1==0 ? [PlayerSet([])] : orderedParts.map{players in PlayerSet(players)})}
//        //orderedKeys=orderedKeys.sorted{$0<$1}
//        //let orderedKeyCount=orderedRPs.count
//        // copy of keyed MSs, trimmed to the shortest to become equi-length, this one will be reduced
//        // we'll be incrementing this and return
//        var finalOrderedMSs=[MatchSetOnCourt]()
//        var iterations=0
//        var RPSetIterations=0
//        // generally we don't play too many in sequence... or when we run out of values (which should not happen often) we stop
//        while(finalOrderedMSs.count<=self.matchSetMaxCountToProduce! && RPSetIterations<=self.matchSetCountPerRestingPlayer!){
//            RPSetIterations+=1
//            //iterate over resting players to increment final list
//            //use a special var for decrementing lists, not sure if this affects the property itself
//            var RPKeyedMSs=self.restPlayerKeyedOrderedMatchSets!.resting mapValues{MSs in Array(MSs[from..<self.lookForwardExtent!])}
//            for restingPlayerSet in self.orderedRPSets!{
//                var remainingForwardMSsPerRP=RPKeyedMSs[restingPlayerSet]!
//                print("remaining forward MS: \(remainingForwardMSsPerRP.count)")
//                if(remainingForwardMSsPerRP.count==0){break}
//                let chosenForwardMSInd:Int
//                let foundDepth:Int?
//                let sourceConstInd:Int?
//                let fromEqui:Bool
//                let historyStartInd=(finalOrderedMSs.count>self.lookBackDepth! ? finalOrderedMSs.count-self.lookBackDepth! : 0)
//                var reversedRecentHistory=Array(finalOrderedMSs[historyStartInd...].reversed())
//                var currentHistLength=reversedRecentHistory.count
//
//                if(finalOrderedMSs.count==0){chosenForwardMSInd=0;foundDepth=nil;sourceConstInd=nil;fromEqui=true}
//                else{
//                        // try to find constraint-satisfying matchset
//                    print("\(finalOrderedMSs.count) history MS(s) to be checked up to depth \(currentHistLength)")
//                    
//                    let indsSet:[Int:[Int?]]=get_next_good_inds_over_history(remainingForwardMSsPerRP, reversedRecentHistMSs: reversedRecentHistory)
//                        
//                    assert(indsSet.count<=currentHistLength)
//                    print(indsSet.sorted(by:{$0.0>$1.0}))
//                        
//                    let (indR,indOfIndR,constIndR,fromEquiR)=pick_ind_from_indsSet(indsSet,constWeights:(self.interMatchSetConstraintFncs.count==2 ? [3.0,1.0] : Array(repeating:1.0, count:self.interMatchSetConstraintFncs.count)))
//                    
//                    if let indOrNil=indR, let indOfIndOrNil=indOfIndR, let constIndOrNil=constIndR, let fromEquiOrNil=fromEquiR{
//                            chosenForwardMSInd=indOrNil;foundDepth=indOfIndOrNil;sourceConstInd=constIndOrNil;fromEqui=fromEquiOrNil
//                        }else{chosenForwardMSInd=0; foundDepth=nil; sourceConstInd=nil; fromEqui=true}
//                    }
//                let beforeRemovalCount=remainingForwardMSsPerRP.count
//                //cause of occasional crash
//                let chosenForwardMS=remainingForwardMSsPerRP.remove(at:chosenForwardMSInd)
//                assert(beforeRemovalCount-1==remainingForwardMSsPerRP.count)
//                if(finalOrderedMSs.count != 0 && foundDepth != nil){print("chosen forward ind: \(chosenForwardMSInd), equi \(fromEqui)"+(!fromEqui ? " constInd \(sourceConstInd!)" : "")+" found at depth \(foundDepth!) of \(currentHistLength)")
//                    if(fromEqui){
//                        for (constCntr,fnc) in self.interMatchSetConstraintFncs.enumerated(){
//                            for (histCntr,histMS) in Array(reversedRecentHistory[0..<foundDepth!]).enumerated(){
//                                assert(fnc(chosenForwardMS,histMS))
//                                       }
//                        }
//                    }
//                }
//                RPKeyedMSs[restingPlayerSet]=remainingForwardMSsPerRP
//                finalOrderedMSs.append(chosenForwardMS)
//            }
//            iterations+=1
//            if (iterations>50){break}
//        }
//        return finalOrderedMSs
//
//        func get_first_equiind_ind(_ indsSet:[Int:[Int?]])->(Int?,Int?){
//            var foundInd:Int?=nil
//            var indOfFoundIndsSet:Int?=nil
//            for (depth,anIndSet) in indsSet.sorted(by: {$0.0>$1.0}){
//                    if(!anIndSet.contains(nil)){
//                        if(all_identical(anIndSet)){
//                            return (anIndSet[0],depth)
//                    }
//                }
//            }
//            return (foundInd,indOfFoundIndsSet)
//        }
//        
//        func pick_ind_from_indsSet(_ indsSet:[Int:[Int?]], constWeights:[Double], igoreRecentN:Int=1)->(Int?,Int?,Int?,Bool?){
//            let highestDepth=indsSet.keys.max()
//            var indsSet0=indsSet
//            if(highestDepth! >= 3){indsSet0.removeValue(forKey: 1);print(indsSet0)}
//
//            let (indR,indOfIndR)=get_first_equiind_ind(indsSet0)
//            if let indOrNil=indR, let indOfIndOrNil=indOfIndR{
//                return (indOrNil,indOfIndOrNil,0,true)
//            }
//            var greatestSoFar:Double?=nil
//            var indSoFar:Int?=nil
//            var indOfIndSoFar:Int?=nil
//            var constIndSoFar:Int?=nil
//            var fromEquiind:Bool?=nil
//            for (cntr,anIndSet) in indsSet0.sorted(by:{$0.0>$1.0}){
//                assert(constWeights.count==anIndSet.count)
//                // if all is nil
//                if(anIndSet.filter{el in el != nil}.isEmpty){continue}
//                //here you're left with a non-equi set with at least one el non-nil
//                for (constInd,ind) in anIndSet.enumerated(){
//                    let candScore=(ind==nil ? 0.0 : ind_depth_metric(weightedInd:Double(ind!)*constWeights[constInd],depth:cntr+1))
//                        if(greatestSoFar == nil || candScore>greatestSoFar!){
//                            greatestSoFar=candScore
//                            indSoFar=ind;indOfIndSoFar=cntr;constIndSoFar=constInd;fromEquiind=false
//                    }
//                }
//            }
//            return (indSoFar,indOfIndSoFar,constIndSoFar,fromEquiind)
//        }
//    }
//
    func ind_depth_metric(weightedInd:Double,depth:Int,weights:(Double,Double)=(1.0,3.0))->Double{
        ((1.0/weightedInd))*weights.0+(Double(depth)/10.0)*weights.1
    }

    
//    func get_restplayerkeyed_matchsets(_ matchSets:[MatchSetOnCourt]){
//        var restPlayerKeyedMatchSets:[String:[MatchSetOnCourt]]=[:]
//        for matchSet in matchSets{
//            let restingPlayersID=PlayerSet(matchSet.restingPlayers).id
//            if let matches=restPlayerKeyedMatchSets[restingPlayersID]{
//                restPlayerKeyedMatchSets[restingPlayersID]!.append(matchSet)}else{
//                    restPlayerKeyedMatchSets[restingPlayersID]=[matchSet]
//                }
//        }
//        // then sort each keyed sets
//        self.order_restkeyed_matchsets(restPlayerKeyedMatchSets)
//    }
    
//    func order_restkeyed_matchsets(_ restPlayerKeyedMatchSets:[PlayerSet:[MatchSetOnCourt]], beam:Bool=false)-> Bool{
//        var myRestPlayerKeyedMatchSets=restPlayerKeyedMatchSets
//        var orderChanged=false
//        for (restSet, matchSetsPerRestset) in myRestPlayerKeyedMatchSets{
//            //let updatedMatchSetsPerRestset=matchSetsPerRestset.map{ms in ms.updated_playerscores()}
//            let myMatchSetsPerRestset=(beam ? Array(matchSetsPerRestset[0..<(matchSetsPerRestset.count>30 ? 30 : matchSetsPerRestset.count)]) : matchSetsPerRestset)
//            let reorderedMSsPerRP=myMatchSetsPerRestset.sorted{$0.totalScoreDiff < $1.totalScoreDiff}
//            if(myMatchSetsPerRestset.map{ms in ms.matchesOnCourt} != reorderedMSsPerRP.map{ms in ms.matchesOnCourt}){
//                orderChanged=true; myRestPlayerKeyedMatchSets[restSet]=reorderedMSsPerRP}
//        }
//        self.restPlayerKeyedOrderedMatchSets=myRestPlayerKeyedMatchSets
//        return orderChanged
//    }
    //updating three things, mark the done MS as finished, restkeyMSs reordering, putting the tip of orderedMSs (current) and mark the done MS finished
    func update_matchsets_onResult()->Bool?{
        let rpMatchSets = self.restingPlayerKeyedMatchSets!
        // updating rpMSs orders
        let changed=rpMatchSets.update_onResult()
        if(changed == nil){return nil}
        // get a new tip MS
        let MSCountBefore=self.orderedMatchSets.count
        if let newMS=self.get_next_constrained_matchset(){
            self.orderedMatchSets.append(newMS.0)}else{return nil}
        assert(MSCountBefore+1==self.orderedMatchSets.count)
        return changed!
    }

    
//    func delete_matchset_from_keyedmatchsets(_ matchSet:MatchSetOnCourt){
//        var hitInd:Int? = nil
//        var hitKey:PlayerSet? = nil
//        var hit=false
//        for (playerSet,MSs) in self.restPlayerKeyedOrderedMatchSets{
//            for (ind,MS) in MSs.enumerated(){
//                if(MS==matchSet){
//                    hitInd=ind
//                    hit.toggle()
//                    break
//                }
//            }
//            if(hitInd != nil){
//                hitKey=playerSet
//                break
//            }
//        }
//        if(hit){
//            self.restPlayerKeyedOrderedMatchSets[hitKey!]?.remove(at:hitInd!)}
//    }

    func restPlayer_fairly_ordered()->Bool{
        let (playingPlayerCount,restPlayerCount)=self.orderedMatchSets[0].playingRestingPlayerCounts
        // if there's no resting player, it's vacuously true
        if restPlayerCount==0{
            return true
        }
        let totalPlayerCount=playingPlayerCount+restPlayerCount
        let expectedInterval=1.0/(Double(restPlayerCount)/Double(totalPlayerCount))
        let firstCycle:Int=Int(floor(expectedInterval))
        // the first round should be all disjoint
        if !all_disjoint(Array(self.orderedMatchSets[0..<firstCycle]).map{matchSet in matchSet.restingPlayerSet.players}){
            print("first round not disjoint")
            return false
        }
        // then the average interval should be more than only a bit less than expected interval
        var restPlayersIndices=[Player:[Int]]()
        for (idx,matchSet) in self.orderedMatchSets.enumerated(){
            let restPlayers=matchSet.restingPlayerSet
            for player in restPlayers.players{
                if restPlayersIndices.keys.contains(player){
                    //let prevInd=restPlayersIndices[player]!.last!
                    //if idx-1==prevInd{
                    //    return false
                    //}
                    restPlayersIndices[player]!.append(idx)
                }else{restPlayersIndices[player]=[idx]}
            }
        }
        let meanIntervals=restPlayersIndices.values.map{inds in mean_interval(inds)}
        return meanIntervals.map{$0>=expectedInterval*0.6}.reduce(true){$0 && $1}
        
    }

    func get_next_good_inds_over_history(_ forwardMSs:[MatchSetOnCourt], reversedRecentHistMSs:[MatchSetOnCourt],  from:Int=0)->[Int:[Int?]]{
        assert(!reversedRecentHistMSs.isEmpty)
        var indsSet:[Int:[Int?]]=[:]
        let histMSCount=reversedRecentHistMSs.count
        let endCount=(histMSCount < self.lookBackDepth! ? histMSCount : self.lookBackDepth!)
            //let startInd=histMSCount<=2 ? 0 : minLen
        for histRevInd in (0..<endCount).reversed(){
            let histDepth=histRevInd+1
            print("checking hist depth \(histDepth)")
            let histMSsPerDepth=Array(reversedRecentHistMSs[..<histDepth])
            assert(histMSsPerDepth.count==histDepth)
            let indsPerHistoryDepth=get_next_good_inds(forwardMSs, reversedRecentHistMSs:histMSsPerDepth)
            indsSet[histDepth]=indsPerHistoryDepth
            // if the same ind satisfies all the consts return what we cumulated
            if(indsPerHistoryDepth.filter{ind in ind == nil}.isEmpty && all_identical(indsPerHistoryDepth)){
                for (histCntr,histMS) in histMSsPerDepth.enumerated(){
                    for (constCntr,const) in self.interMatchSetConstraintFncs.enumerated(){
                        assert(const(histMS,forwardMSs[indsPerHistoryDepth[0]!]))
                    }
                }
                return indsSet}
        }
        return indsSet
    }

    //returns an equi-value inds if there is a MS satisfying all consts, if not, first position satisfying each
    func get_next_good_inds(_ forwardMSs:[MatchSetOnCourt], reversedRecentHistMSs:[MatchSetOnCourt], from:Int=0)->[Int?]{
        let fncCount:Int=self.interMatchSetConstraintFncs.count
        //this is the initial attempt, return the first indices as it automatically satisfies consts
        if(reversedRecentHistMSs.isEmpty){return Array(repeating: 0, count: fncCount)}
        
        // will record successful inds for all consts, initialised with nil's
        var indsSoFar:[Int?]=Array(repeating:nil, count:fncCount)

        //iterate over forward MSs, checking which constraint each satisfies against all the history MSs
        for (forwardMSCntr, forwardMS) in forwardMSs[from...].enumerated(){
            //print("Forward ind \(forwardMSCntr)")
            for (constCntr,const) in self.interMatchSetConstraintFncs.enumerated(){
                if(binaryConst_satisfied_with_anEl_against_allElsInList(fnc: const, with: forwardMS, againstList: reversedRecentHistMSs)){
                    //print("success on const \(constCntr)")
                    indsSoFar[constCntr]=forwardMSCntr
                }//else{print("failed on const \(constCntr)")}
            }
            //returning when equi-ind, otherwise do more iteration
            if(indsSoFar.filter{ind in ind == nil}.isEmpty && all_identical(indsSoFar)){
                for (histCntr,histMS) in reversedRecentHistMSs.enumerated(){
                    for (constCntr,const) in self.interMatchSetConstraintFncs.enumerated(){
                        assert(const(histMS,forwardMSs[indsSoFar[0]!]))
                    }
                }
                return indsSoFar}
        }
        return indsSoFar
    }

    
//    func get_next_good_ind_strong(_ matchSets:[MatchSetOnCourt], reversedRecentHistMSs:[MatchSetOnCourt], from:Int=0)->Int?{
//
//        var fncs=[(MatchSetOnCourt,MatchSetOnCourt)->Bool]()
//        let lastInd = matchSets.count-1
//        var searchExtent:Int {Int(Double(lastInd)*self.constraintApplicationProportion)}
////        var satisfiedInd:Int?=nil
//
//        var searchUpTo:Int {(from+searchExtent <= lastInd ? from+searchExtent : lastInd)}
//        
//        if matchSets[0].sizedCourtCounts.keys.contains(2){fncs.append(singlesPlayerNotShared_p)}
//        if matchSets[0].sizedCourtCounts.keys.contains(4){fncs.append(doublesTeamNotShared_p)}
//        for (cntr, matchSet) in matchSets[from..<searchUpTo].enumerated(){
//            if(satisfy_allconstraints_allmatchsets(matchSet,histMatchSets:reversedRecentHistMSs,fncs:fncs)){
//               // print("constraints satisfied at \(from+cntr)")
//                return from+cntr
//            }
//        }
//        return nil
//        }
// 

    func find_shareRates_atIntervals0(_ matchSets:[MatchSetOnCourt])->[(Int,(Double,Double))]{
        var prevSet=matchSets[0]
        var indsShares=[(Int,(Double,Double))]()
        for (idx,matchSet) in matchSets.enumerated(){
            if idx==0{
                prevSet=matchSet
                continue
            }
            let dShareR=matchSet.doublesTeamShare_rate(prevSet)!
            let sShareR=matchSet.singlesPlayerShare_rate(prevSet)!
            //let shareR=(dShareR+sShareR)/2
            if sShareR+dShareR>0.0{
                indsShares.append((idx,(dShareR,sShareR)))
            }
        }
        return indsShares
    }
}

func binaryConst_satisfied_with_anEl_against_allElsInList<U:Equatable>(fnc:(U,U)->Bool,with:U,againstList:[U])->Bool{
    for el in againstList{
        if(!fnc(with,el)){return false}
    }
    return true
}

func find_shareRates_atIntervals(_ matchSets:[MatchSetOnCourt], shareFncs:[ (MatchSetOnCourt,MatchSetOnCourt)->Double? ]  ) ->[[Double]]{
    var prevSet=matchSets[0]
    var shareRates=[[Double]]()
    for matchSet in matchSets[1...]{
        var ratesPerInterval=[Double]()
        for shareFnc in shareFncs{
            ratesPerInterval.append(shareFnc(prevSet,matchSet)!)
        }
        shareRates.append(ratesPerInterval)
    }
    return shareRates
}

func apply_intermatchset_constraints(_ matchSets:[MatchSetOnCourt],firstPart:Int)->[MatchSetOnCourt]{
    var constrainedMatchSets:[MatchSetOnCourt]
    constrainedMatchSets=apply_intermatchset_constraints_firstpart(matchSets,firstPart:firstPart)
    return constrainedMatchSets[0..<firstPart]+apply_intermatchset_constraints_loop(Array(constrainedMatchSets[firstPart...]))
}

func apply_intermatchset_constraints_firstpart(_ matchSets:[MatchSetOnCourt], firstPart:Int)->[MatchSetOnCourt]{
    var newMatchSets=matchSets
    return newMatchSets
}

func apply_intermatchset_constraints_loop(_ matchSets:[MatchSetOnCourt])->[MatchSetOnCourt]{
    var orderedGoodMatchSets=matchSets
    let matchSetCount=orderedGoodMatchSets.count
    let inds2do:Int=(matchSetCount>10 ? 5 : matchSetCount/2)
    var sharedRates:[[Double]]
    let shareFncs=[doublesTeamShare_rate]
    // this is a compromise because 1: only adjacent matchsets are considered 2: may discard otherwise good matchsets
    var trials=0
    repeat {
        //sharedIndsRates=find_shareRates_atIntervals0(Array(orderedGoodMatchSets[0..<inds2do]))
        sharedRates=find_shareRates_atIntervals(Array(orderedGoodMatchSets[0..<inds2do]),shareFncs:shareFncs)
        var meanRate=0.0
        for (cntr, ratesAcrossFncs) in sharedRates.enumerated(){
            let rates=sum(ratesAcrossFncs)
            if(rates>0.0){
                let extracted=orderedGoodMatchSets.remove(at:cntr)
                orderedGoodMatchSets.append(extracted)
                meanRate=(meanRate+rates)/2
            }
        }
        trials+=1
        // due to 2 above, we only do a limited no. of times
        if trials>3{if (meanRate<0.5){print("1st leniency");break}}
        if trials>6{if (meanRate<0.75){print("2nd leniency");break}}
        if(trials>9){if (meanRate<1.0){print("3rd leniency");break}
        }
        if(trials>12){print("iteration limit reached");break}
    }while(!sharedRates.isEmpty)
    
    return orderedGoodMatchSets
}

//used for ordering RP sets
func partition_based_ordering<U:Hashable>(_ elements:[U], _ repeatCounts:[Int])->[[U]]{
    assert(!repeatCounts.isEmpty)
    assert(!repeatCounts.contains(0))
    assert(elements.count>=sum(repeatCounts))
        print("resting players being ordered...")
        let partitions=get_partitions_withIntegers_generative(elements, repeatCounts)
        var orderedPartitions:[[U]]=[]
    for partition in partitions{//.shuffled(){
            for part in partition{
                    orderedPartitions.append(part)
            }
        }
        return orderedPartitions
     
    }
        
func satisfied_constraints_allmatchsets(_ matchSet:MatchSetOnCourt, histMatchSets:[MatchSetOnCourt], fncs:[(MatchSetOnCourt,MatchSetOnCourt)->Bool])->[[Bool]]{
    var satisBoolSets=[[Bool]]()
    for histMatchSet in histMatchSets{
        var bools=[Bool]()
        for fnc in fncs{
            bools.append(fnc(matchSet,histMatchSet))
        }
        satisBoolSets.append(bools)
    }
    return satisBoolSets
}
func get_partitions_withIntegers_generative<T:Hashable>(_ myList:[T], _ ints:[Int], stopCount:Int=10)-> [[[T]]]{
    assert(myList.count>=sum(ints))
    var partitions=[[[T]]]()
    let upperBound=count_intpartitions(ints)
    let limit=(stopCount>upperBound ? upperBound : stopCount)
    var cntr=0
    while (partitions.count<limit || cntr>100){
        let cand=generate_partition_randomly(myList, ints)
        if !partitions.contains(cand){
            partitions.append(cand)
        }
        cntr+=1
    }
    return partitions
}

func generate_partition_randomly<T:Hashable>(_ myList:[T], _ ints:[Int])->[[T]]{
    var complement=myList
    var newPartition=[[T]]()
    for int in ints{
        var part=[T]()
        for _ in (0..<int){
            let pickedEl=complement.randomElement()!
            part.append(pickedEl)
            complement=complement.filter{$0 != pickedEl}}
        newPartition.append(part)
    }
    return newPartition
}

//// there could be a remainder left afterwards, i.e. there can be more orgList els than the sum of ints
//func get_partitions_withIntegers<T:Hashable>(_ orgList:[T], _ ints:[Int], setsToExclude:Set<Set<T>>=Set(), doPotentiallyRandomPrune:Bool=false, debug:Bool=false)-> [([[T]],[T])]{
//
//    var partitionsWithRemainder:[([[T]],[T])]=[([],orgList)]//to be returned
//
//    let doPrune=(!setsToExclude.isEmpty || doPotentiallyRandomPrune)
//    assert(sum(ints)<=orgList.count)
//    assert(!orgList.isEmpty)
//    assert(!ints.isEmpty)
//    
//    if(ints.count==1){
//        return combos_withRemainder(elements: orgList, k: ints[0]).map{(combo,remainder) in ([combo],remainder)}
//    }
//    
//    let remainderCountAtTheEnd=orgList.count - sum(ints)
//    let ints=ints.sorted()
//    let intLen=ints.count
//    let lastInd=intLen-1
//    let expectedFinalCount=count_intpartitions(ints, remainder:remainderCountAtTheEnd)
//    var prevCombs=[[T]]()
//    for (cntr,currentInt) in ints.enumerated(){
//        let isLastItem=(cntr==lastInd)
//        if(debug){print("partition index \(cntr) in \(ints) "+(isLastItem ? "(final)" : "")+" to be done...")}
//        let nextIsLast=(cntr+1==lastInd)
//        //let sameAsPreviousInt=(currentInt==prevInt)
//        let nextSkip = remainderCountAtTheEnd==0 && nextIsLast
////        let willHaveRemainderNext=true
//        //nil there isn't a next thing
//        let nextIntWillBeSame:Bool?=(nextIsLast ? nil : currentInt==ints[cntr+1])
//        let prevPartCnt=partitionsWithRemainder.count
//                
//        //we skip the last int comb gen if there's no remainder for efficiency
//        
//        //        if(lastSkip)else{
//        partitionsWithRemainder=extend_partitions(partitionsWithRemainder, currentInt, setsToExclude:setsToExclude, nextIntWillBeSame:nextIntWillBeSame, doPotentiallyRandomPrune:doPotentiallyRandomPrune, debug:debug)
//        if(debug){print("partitions"+(isLastItem ? " finally" : " now")+" number \(partitionsWithRemainder.count) after \(cntr) extensions")}
//        let remainderVariety=partitionsWithRemainder.map{(_part,rem) in Set(rem) }.reduce(Set()){$0.union($1)}
//        //assert(remainderVariety.count==orgList.count)
//        if(nextIsLast && remainderCountAtTheEnd==0){if(debug){print("skipping last int extension")}
//            assert(expectedFinalCount==partitionsWithRemainder.count)
//            return partitionsWithRemainder.map{(part,rem) in (part+[rem], [])} }
//        
//        if(!isLastItem){assert(partitionsWithRemainder.count>=prevPartCnt)}
//    }
//        
//    return partitionsWithRemainder
//    
//    
//    func extend_partitions<U:Hashable>(_ orgPartitionsWithRemainder:[([[U]],[U])],_ anInt:Int, setsToExclude:Set<Set<U>>, nextIntWillBeSame:Bool?, doPotentiallyRandomPrune:Bool, debug:Bool=false)-> [([[U]],[U])]{
//        var newPartitionsWithRemainder=[([[U]],[U])]()
//        let willBeLastNext:Bool=partitionsWithRemainder[0].1.count/anInt==1
//        let willHaveRemainderNext:Bool=partitionsWithRemainder[0].1.count-anInt != 0
//        let partitionCount=partitionsWithRemainder.count
//        let partCountTotal=partitionsWithRemainder[0].0.map{part in part.count}.reduce(0,+)
////        let remainingEls=baseElements.count-partCountTotal
//        let remainderCount=partitionsWithRemainder[0].1.count
//        let complexityScale=partitionCount*remainderCount
//        let thresh=1000
//        let proportionUpTo:Double
//        let doRandomlyPrune=(doPotentiallyRandomPrune && complexityScale>thresh)
//        let doPrune=(doRandomlyPrune || !setsToExclude.isEmpty)
//        let ints:[Int]=partitionsWithRemainder[0].0.map{part in part.count}+[anInt]
//        let elCount:Int=ints.reduce(0,+)
//        let lastParts=partitionsWithRemainder.map{(partition,_rem) in partition.last ?? [] }
//        let lastPartCount=lastParts[0].count
//        
//        switch complexityScale{
//        case 0..<500:proportionUpTo=0.0
//        case 500..<8000:proportionUpTo=0.3
//        case 8_000..<50_000:proportionUpTo=0.2
//        case 5_0000..<100_000:proportionUpTo=0.1
//        case 100_000..<1_000_000: proportionUpTo=0.05
//        case 500_000..<1_000_000: proportionUpTo=0.02
//        default: proportionUpTo=0.01
//        }
//        if(doPrune && debug){print("complexity scale \(complexityScale)"+(complexityScale<thresh ? "": ", larger than the thresh \(thresh), pruning at \(proportionUpTo)"))}
//        for (cntr,(orgPart,remainingElements)) in orgPartitionsWithRemainder.enumerated(){
//            if (cntr != 0 && cntr%1000==0){if(debug){print("\(cntr) done, partitions counting \(partitionsWithRemainder.count)")}}
////            var elDoneCount=0;
//            var prevFirstEl:U?=nil
//            let comboCount=combo_count(n:anInt+remainingElements.count,k:anInt)
//            var setOfLastTwoParts:[[[U]]]=[]
//            for (comboCntr,(comb,remainder)) in (doRandomlyPrune ? randomly_generate_disjoint_combos(elements: Array(remainingElements), k: anInt, proportionUpTo: proportionUpTo) : combos_withRemainder(elements:Array(remainingElements),k:anInt)).enumerated(){
//                    //if(complexityScale<=thresh && doPrune && comboCntr%pruneQuotient != 0){
//                      //  continue}
//                if(comboCntr>=1 && (nextIntWillBeSame ?? false) && prevFirstEl! != comb[0]){
////                    elDoneCount+=1
//                    if(comboCntr>comboCount/2){continue}
//                }
//                let lastPart=newPartitionsWithRemainder.last!.0.last!
//                let candLastTwoParts=[lastPart, comb]
//                    if(!setsToExclude.isEmpty && setsToExclude.contains(Set(comb))){continue}
////                    if((nextIntWillBeSame ?? false) && !comb.contains(remainingElements[0])){continue}
//                    let candPart=orgPart+[comb]
//                    let candPartWithRem=(candPart, get_remainder(comb, superArray: remainder))
//                if(cntr>=1){
//                    if (lastPartCount == anInt){
//                        if(setOfLastTwoParts.contains(candLastTwoParts)){continue}}
//                
//                }
//                newPartitionsWithRemainder.append(candPartWithRem)
//                setOfLastTwoParts.append(candLastTwoParts)
//                        
//                
////                    else{
////                            if (combsWithRemainder.filter{aPart in order_variants_partition(aPart.0, candPartWithRem.0)}.isEmpty){
////                                combsWithRemainder.append(candPartWithRem)}else{if(debug){print("duplicate found")}}
////                        }
//                prevFirstEl=comb[0]
//
//            }
//            
//        }
//        
//            return newPartitionsWithRemainder
//        }
//        
//    }
//
//if !seenParts.filter({aPart in order_variants_partition(aPart,part)}).isEmpty{


    
func teams_nooverlap_p(_ teams:[Team])-> Bool{
    var seenPlayers=Set<Player>()
    var playersInTeam:Set<Player>
    for team in teams{
        playersInTeam=Set(team.players.flatMap{$0})
        if !seenPlayers.intersection(playersInTeam).isEmpty{
            return false
        }
        seenPlayers=seenPlayers.union(playersInTeam)
    }
    return true
}

func matches_nooverlap_p(_ matches:[Match])-> Bool{
    var seenPlayers=Set<Player>()
    var playersInTeam:Set<Player>
    for match in matches{
        playersInTeam=Set(match.listOfPlayers.flatMap{$0})
        if !seenPlayers.intersection(playersInTeam).isEmpty{
            return false
        }
        seenPlayers=seenPlayers.union(playersInTeam)
    }
    return true
}

func matchsets_ordered(_ matchSets:[MatchSetOnCourt])->Bool{
    var prev=matchSets[0]
    for msoc in matchSets[1...]{
        if prev.totalScoreDiff>msoc.totalScoreDiff{
            return false
        }
    }
    return true    
}
