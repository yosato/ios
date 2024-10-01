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
        self.id=self.players.map{player in player.id}.joined(separator: "_")
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
    
    func get_balanced_matches(matchSizes:[Int]=[2,4],coeff:Double=1.2)-> [Int:[PlayerSet:[Match]]]{
            var sizedPlayerSetKeyedMatches=[Int:[PlayerSet:[Match]]]()
            for matchSize in matchSizes{
                var chosenCount=0
                var totalCount:Int=0
                var playerSetKeyedMatches=[PlayerSet:[Match]]()
                for (cntr,playersPerMatch) in combos(elements:self.sortedPlayers,k:matchSize).enumerated(){
                    let mergedPlayerSet=PlayerSet(playersPerMatch)
                    playerSetKeyedMatches[mergedPlayerSet]=[]
                    var matches=[Match]()
                    let teamSize=matchSize/2
                    let partitionsWithRemainder=get_partitions_withIntegers(playersPerMatch,Array(repeating:teamSize, count:2),doPotentiallyPrune: false)
                    for (partCntr,(partition,_)) in partitionsWithRemainder.enumerated(){
                        assert(partition.count==2)
                        let team1=Team(partition[0]); let team2=Team(partition[1])
                        if(abs(team1.meanScore-team2.meanScore)<self.stddev*(coeff/Double(teamSize))){
                            playerSetKeyedMatches[mergedPlayerSet]!.append(Match([team1,team2]))
                            chosenCount+=1}
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
        {players.append(player)}
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
    func update_playerscores_matchResults(_ matchResults:MatchResults){
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
    let restingPlayers:[Player]
    
    var doublesOnlyP:Bool {sizedCourtCounts.keys.count==1 && sizedCourtCounts.keys.contains(4)}
    var singlesOnlyP:Bool {sizedCourtCounts.keys.count==1 && sizedCourtCounts.keys.contains(2)}
    var mixedP:Bool {!singlesOnlyP && !doublesOnlyP}
    var sizedWeights:[Int:Double] {mixedP ? [2:0.3,4:0.7] : (doublesOnlyP ? [4:1.0] : [2:1.0])}
    
    var matchesOnCourt:[Match] {(sizedMatchesOnCourt[4] ?? [])+(sizedMatchesOnCourt[2] ?? [])}

    var playingPlayers:[Player]  {matchesOnCourt.map{match in match.listOfPlayers}.flatMap{$0}}
    var allPlayers:[Player]  {playingPlayers+restingPlayers}
    
    var allTeamOppositions:[(Team,Team)] {matchesOnCourt.map{$0.teams}}
    var playingRestingPlayerCounts:(Int,Int) {(self.playingPlayers.count, self.restingPlayers.count)}
    
    func hash(into hasher: inout Hasher){
        hasher.combine([sizedMatchesOnCourt])
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
    
    init(_ sizedMatches:[Int:[Match]], sizedCourtCounts:[Int:Int], restingPlayers:[Player]=[]){
        self.sizedMatchesOnCourt=sizedMatches
        self.restingPlayers=restingPlayers
        self.sizedCourtCounts=sizedCourtCounts
        //self.myPlayers=myPlayers
    }
    init(_ matches:[Match], restingPlayers:[Player]){
        var sizedMatches=[Int:[Match]](); var sizedCC=[Int:Int]()
        for match in matches{
            let playerCount=match.listOfPlayers.count
            if let _=sizedMatches[playerCount]{sizedMatches[playerCount]!.append(match)}else{sizedMatches[playerCount]=[match]}
            if let _=sizedCC[playerCount]{sizedCC[playerCount]!+=1}else{sizedCC[playerCount]=1}
        }
                    
        self.sizedMatchesOnCourt=sizedMatches
        self.restingPlayers=restingPlayers
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


class GoodMatchSetsOnCourt:ObservableObject{
    
    @Published var orderedMatchSets:[MatchSetOnCourt]=[]
    @Published var courtCount:Int=1
    var restPlayerKeyedOrderedMatchSets:[String:[MatchSetOnCourt]]=[:]
    let lookForwardProportion=0.5
    let pruneQuotient=20

    // these properties become available with the main function, get_best_matches
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

    
    func all_share_players()->Bool{
        return true
    }
    


    // THIS IS THE MAIN FUNC!
    func get_best_matchsets(_ playersOnCourt:PlayersOnCourt, _ courtCount:Int){
        //setting basic vars
        self.sizedCourtCount=assign_courtTeamsize(courtCount: courtCount, playerCount: playersOnCourt.players.count)
        let playingPlayerCount:Int=self.sizedCourtCount!.map{(size,count) in size*count}.reduce(0,+)
        self.allPlayers=playersOnCourt.players
        self.playingRestingPlayerCounts=(playingPlayerCount,self.allPlayers!.count-playingPlayerCount)
        if(self.sizedCourtCount!.keys.contains(2)){self.interMatchSetConstraintFncs.append(singlesPlayerNotShared_p)}
        if(self.sizedCourtCount!.keys.contains(4)){self.interMatchSetConstraintFncs.append(doublesTeamNotShared_p)}
        
        let startTime=Date()
        print(Date())
        print("initial matchsets...")
        let sizePlayerKeyedMatches=playersOnCourt.get_balanced_matches(matchSizes:Array(self.sizedCourtCount!.keys))
       // let sizesCounts=sizeTeamKeyedMatches.map{(size,matches) in (size,matches.count)}
       // print("...prepared, there are \(sizesCounts) matches to choose from out of total")

        // get all matchsets, resting-player 'team' classified
        print("getting possible combinations per rest players...")

        var RPKeyedMSs=self.get_good_matchsets(self.sizedCourtCount!, sizePlayerKeyedMatches, playersOnCourt)
        //assert(!matchset_duplicate_p(goodMatchSets))
        print("... combinations done")
        // ordering
        print("ordering matchsets per RP...")
        for (RP,MSs) in RPKeyedMSs{
            print("ordering for RP \(RP) done")
            RPKeyedMSs[RP]=MSs.sorted{$0.totalScoreDiff<$1.totalScoreDiff}
        }
        let shortestCnt:Int=RPKeyedMSs.values.map{MS in MS.count}.min() ?? 0
        self.restPlayerKeyedOrderedMatchSets=RPKeyedMSs.mapValues{val in Array(val[0..<shortestCnt-1])}
        
        if(shortestCnt<100){self.lookBackDepth=3;self.matchSetMaxCountToProduce=6}else if(shortestCnt<500){self.lookBackDepth=4;self.matchSetMaxCountToProduce=10}else if(shortestCnt<1000){self.lookBackDepth=4;self.matchSetMaxCountToProduce=20}else{self.lookBackDepth=5;self.matchSetMaxCountToProduce=20}
        self.lookForwardExtent=Int(self.lookForwardProportion*Double(shortestCnt))
        print("PerRP MS count to be trimmed to \(shortestCnt) (top \(self.lookForwardProportion*100)%, i.e. \(self.lookForwardExtent!) will be searched against \(self.lookBackDepth!))")
        self.matchSetCountPerRestingPlayer=shortestCnt
        print("enforcing constraints...")
        self.orderedMatchSets=self.get_constrained_ordered_matchsets()
       // assert(!matchset_duplicate_p(orderedGoodMatchSets))
        print("All done")
        let endTime=Date()
        let timeElapsed=endTime.timeIntervalSince(startTime)
        print(endTime)
        print(timeElapsed)
//        let finalMatchSets=apply_intermatchset_constraints(orderedGoodMatchSets,firstPart:6)
        
//        self.orderedMatchSets=finalMatchSets
        self.courtCount=courtCount
        
    }
    
    // all the heavy lifting
    func get_good_matchsets(_ sizedCourtCounts:[Int:Int], _ sizePlayerKeyedMatches:[Int:[PlayerSet:[Match]]], _ playersOnCourt:PlayersOnCourt)->[String:[MatchSetOnCourt]]{
        // to be returned, a matchSetOnCourt is a set of player-exclusive matches happening at a time on multiple courts
        // flat list of matchSetOnCourts will be returned, with the concurrent match count length
        var restingPlayerKeyedMatchSetsOnCourt=[String:[MatchSetOnCourt]]()
        // e.g. for 12 people with 4 courts, we'll have 2singlesx2 + 2doublesx4 = 12. Each element, i.e. a matchSetCourt, will consist of four matches, 2 singles, 2 doubles
                
        // the trick for efficiency is to first prepare player-exclusive combinations
        // e.g. for {2:2,4:2} (2 singles, 2 doubles) with 12 players p1...p10, we prepare possible combos like Match(p1 v p2), M(p3 v p4), M((p5,p6)v(p7,p8)) and M((p9,p10)v(p11,p12))
        
        var ints=[Int]()
        for (size,count) in sizedCourtCounts{
            ints+=Array(repeating:size,count:count)
        }
        //injecting restplayer count at the top if exists
        //injecting restplayer count at the top iloof exists
//        if(restingExists!){ints=[self.playingRestingPlayerCounts!.1]+ints}
        var playerSetsToExclude=Set<Player>()
        for playerKeyedMatches in sizePlayerKeyedMatches.values{
            for (playerSet,matches) in playerKeyedMatches{
                if(matches.isEmpty){playerSetsToExclude=playerSetsToExclude.union(Set(playerSet.players))}
            }
        }
        
        let playingPlayerPartitionsWithRemainder=get_partitions_withIntegers(playersOnCourt.players, ints, setsToExclude:playerSetsToExclude, pruneQuotient:self.pruneQuotient, doPotentiallyPrune:true, debug:true)
        //let haveRestingPlayers:Bool=(playersOnCourt.players.count==sum(ints) ? false : true)
        // a player partition is a court-count numbered set of mutually excl. player sets e.g. ((p1,p2),(p3,p4),(p5,p6,p7,p8),(p9,p10,p11,p12)) for four courts
        
        //restingplayer-keyed MSs
        print("creating RP key-based MSs...")
        for (cntr,(playingPlayerPartition,restingPlayers)) in playingPlayerPartitionsWithRemainder.enumerated(){
            if(cntr != 0 && cntr%2000==0){print(cntr)}
            var matchSetsOnCourt:[MatchSetOnCourt]=[]
//            let restingPlayers=(restingExists! ? playerPartition[0] : [])
            let restingPlayersString=restingPlayers.map{player in player.id}.joined(separator:"--")
            let possibleMatchSets=get_balancedMatches(playingPlayerPartition,sizePlayerKeyedMatches)
            if (!possibleMatchSets.isEmpty){
                for possibleMatchSet in possibleMatchSets{
                    let playingPlayers:[Player]=possibleMatchSet.map{match in match.listOfPlayers}.flatMap{$0}
                    let restingPlayers:[Player]=playersOnCourt.players.filter{player in !playingPlayers.contains(player)}
                    matchSetsOnCourt.append(MatchSetOnCourt(possibleMatchSet, restingPlayers: restingPlayers))
                }
                if(restingPlayerKeyedMatchSetsOnCourt[restingPlayersString] != nil){
                    restingPlayerKeyedMatchSetsOnCourt[restingPlayersString]!+=matchSetsOnCourt}else{
                    restingPlayerKeyedMatchSetsOnCourt[restingPlayersString]=matchSetsOnCourt}
            }
        }
        if(self.playingRestingPlayerCounts!.1 != 0){
            assert(restingPlayerKeyedMatchSetsOnCourt.keys.count==self.allPlayers!.count)
            print(restingPlayerKeyedMatchSetsOnCourt.values.map{key in key.count})
        }else{assert(restingPlayerKeyedMatchSetsOnCourt.keys.count==1)}
        return restingPlayerKeyedMatchSetsOnCourt
        
        func get_balancedMatches(_ playerPartition:[[Player]], _ twoKeyedMatches:[Int:[PlayerSet:[Match]]])->[[Match]]{
            var matchSets=[[Match]]()
            if !all_key_present(playerPartition,twoKeyedMatches){
                return matchSets
            }

            for playersPerCourt in playerPartition{
                var matchesPerGroup=[Match]()
                let size=playersPerCourt.count
                matchesPerGroup+=twoKeyedMatches[size]![PlayerSet(playersPerCourt)]!
                       
                matchSets.append(matchesPerGroup)
                
            }
            
            let matchSeries=generalised_product(matchSets)
                        
            return matchSeries
            
            func all_key_present(_ playerPartition:[[Player]], _ twoKeyedMatches:[Int:[PlayerSet:[Match]]])-> Bool{
                for playersPerCourt in playerPartition{
                    let size=playersPerCourt.count
                    if !twoKeyedMatches[size]!.keys.contains(PlayerSet(playersPerCourt)){
                        return false
                    }
                }
                return true
            }
        }
    }
    
    
    func get_constrained_ordered_matchsets(from:Int=0)->[MatchSetOnCourt]{
        let totalCount=self.playingRestingPlayerCounts!.0+self.playingRestingPlayerCounts!.1
        let repetitionCount:Int=(self.playingRestingPlayerCounts!.1==0 ? 1 : totalCount/self.playingRestingPlayerCounts!.1)
        let (orderedParts,frequentResterParts)=partition_based_ordering(self.allPlayers!, Array(repeating:playingRestingPlayerCounts!.1,count:repetitionCount), frequentResterIDs:frequentResterIDs)
        var orderedRPIDs:[String]=(playingRestingPlayerCounts!.1==0 ? [""] : orderedParts)
        //orderedKeys=orderedKeys.sorted{$0<$1}
        //let orderedKeyCount=orderedRPs.count
        // copy of keyed MSs, trimmed to the shortest to become equi-length, this one will be reduced
        // we'll be incrementing this and return
        var finalOrderedMSs=[MatchSetOnCourt]()
        var iterations=0
        // generally we don't need more than 20... or when we run out of values we stop
        while(finalOrderedMSs.count<=self.matchSetMaxCountToProduce! ){
            // the order of rests changes randomly in each iteration.
               orderedRPIDs = orderedRPIDs.shuffled()
            
            //iterate over resting players to increment final list
            //use a special var for decrementing lists, not sure if this affects the property itself
            var RPKeyedMSs=self.restPlayerKeyedOrderedMatchSets.mapValues{MSs in Array(MSs[0..<self.lookForwardExtent!])}
            for restingPlayer in orderedRPIDs{
                var remainingForwardMSsPerRP=RPKeyedMSs[restingPlayer]!
                let chosenForwardMSInd:Int
                let foundDepth:Int?
                let sourceConstInd:Int?
                let fromEqui:Bool
                let historyStartInd=(finalOrderedMSs.count>self.lookBackDepth! ? finalOrderedMSs.count-self.lookBackDepth! : 0)
                var reversedRecentHistory=Array(finalOrderedMSs[historyStartInd...].reversed())
                var currentHistLength=reversedRecentHistory.count

                if(finalOrderedMSs.count==0){chosenForwardMSInd=0;foundDepth=nil;sourceConstInd=nil;fromEqui=true}
                else{
                        // try to find constraint-satisfying matchset
                    print("\(finalOrderedMSs.count) history MS(s) to be checked up to depth \(currentHistLength)")
                    
                    let indsSet:[Int:[Int?]]=get_next_good_inds_over_history(remainingForwardMSsPerRP, reversedRecentHistMSs: reversedRecentHistory)
                        
                    assert(indsSet.count<=currentHistLength)
                    print(indsSet.sorted(by:{$0.0>$1.0}))
                        
                    let (indR,indOfIndR,constIndR,fromEquiR)=pick_ind_from_indsSet(indsSet,constWeights:(self.interMatchSetConstraintFncs.count==2 ? [3.0,1.0] : Array(repeating:1.0, count:self.interMatchSetConstraintFncs.count)))
                    
                    if let indOrNil=indR, let indOfIndOrNil=indOfIndR, let constIndOrNil=constIndR, let fromEquiOrNil=fromEquiR{
                            chosenForwardMSInd=indOrNil;foundDepth=indOfIndOrNil;sourceConstInd=constIndOrNil;fromEqui=fromEquiOrNil
                        }else{chosenForwardMSInd=0; foundDepth=nil; sourceConstInd=nil; fromEqui=true}
                    }
                let beforeRemovalCount=remainingForwardMSsPerRP.count
                let chosenForwardMS=remainingForwardMSsPerRP.remove(at:chosenForwardMSInd)
                assert(beforeRemovalCount-1==remainingForwardMSsPerRP.count)
                if(finalOrderedMSs.count != 0 && foundDepth != nil){print("chosen forward ind: \(chosenForwardMSInd), equi \(fromEqui)"+(!fromEqui ? " constInd \(sourceConstInd!)" : "")+" found at depth \(foundDepth!) of \(currentHistLength)")
                    if(fromEqui){
                        for (constCntr,fnc) in self.interMatchSetConstraintFncs.enumerated(){
                            for (histCntr,histMS) in Array(reversedRecentHistory[0..<foundDepth!]).enumerated(){
                                assert(fnc(chosenForwardMS,histMS))
                                       }
                        }
                    }
                }
                RPKeyedMSs[restingPlayer]=remainingForwardMSsPerRP
                finalOrderedMSs.append(chosenForwardMS)
            }
            iterations+=1
            if (iterations>50){break}
        }
        return finalOrderedMSs
        
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

    func ind_depth_metric(weightedInd:Double,depth:Int,weights:(Double,Double)=(1.0,3.0))->Double{
        ((1.0/weightedInd))*weights.0+(Double(depth)/10.0)*weights.1
    }

    func all_identical<T:Equatable>(_ anArray:[T])->Bool{
        if(anArray.count<=1){return true}
        let firstEl=anArray[0]
        return anArray[1...].allSatisfy{firstEl==$0}
    }
    
    func get_restplayerkeyed_matchsets(_ matchSets:[MatchSetOnCourt]){
        var restPlayerKeyedMatchSets:[String:[MatchSetOnCourt]]=[:]
        for matchSet in matchSets{
            let restingPlayersID=PlayerSet(matchSet.restingPlayers).id
            if let matches=restPlayerKeyedMatchSets[restingPlayersID]{
                restPlayerKeyedMatchSets[restingPlayersID]!.append(matchSet)}else{
                    restPlayerKeyedMatchSets[restingPlayersID]=[matchSet]
                }
        }
        // then sort each keyed sets
        self.order_restkeyed_matchsets(restPlayerKeyedMatchSets)
    }
    
    func order_restkeyed_matchsets(_ restPlayerKeyedMatchSets:[String:[MatchSetOnCourt]], beam:Bool=false){
        var myRestPlayerKeyedMatchSets=restPlayerKeyedMatchSets
        for (restSet, matchSetsPerRestset) in myRestPlayerKeyedMatchSets{
            //let updatedMatchSetsPerRestset=matchSetsPerRestset.map{ms in ms.updated_playerscores()}
            var myMatchSetsPerRestset=(beam ? Array(matchSetsPerRestset[0..<(matchSetsPerRestset.count>30 ? 30 : matchSetsPerRestset.count)]) : matchSetsPerRestset)
            //myMatchSetsPerRestset=(update ? myMatchSetsPerRestset.map{ms in ms.updated_playerscores()} : matchSetsPerRestset)
            myRestPlayerKeyedMatchSets[restSet]=myMatchSetsPerRestset.sorted{$0.totalScoreDiff < $1.totalScoreDiff}
        }
        self.restPlayerKeyedOrderedMatchSets=myRestPlayerKeyedMatchSets
    }

    func reorder_matchsets(from:Int){
        let finishedMatchSets=Array(self.orderedMatchSets[0..<from])
        for finishedMS in finishedMatchSets{
            self.delete_matchset_from_keyedmatchsets(finishedMS)
        }
        print("re-ordering restplayer based queues...")
        self.order_restkeyed_matchsets(self.restPlayerKeyedOrderedMatchSets, beam:true)
        print("re-enforcing constraints...")
        self.get_constrained_ordered_matchsets(from:from)
        print("... done")
    }
    
    
    func delete_matchset_from_keyedmatchsets(_ matchSet:MatchSetOnCourt){
        var hitInd:Int? = nil
        var hitKey:String? = nil
        var hit=false
        for (playerSetID,MSs) in self.restPlayerKeyedOrderedMatchSets{
            for (ind,MS) in MSs.enumerated(){
                if(MS==matchSet){
                    hitInd=ind
                    hit.toggle()
                    break
                }
            }
            if(hitInd != nil){
                hitKey=playerSetID
                break
            }
        }
        if(hit){
            self.restPlayerKeyedOrderedMatchSets[hitKey!]?.remove(at:hitInd!)}
    }

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
        if !all_disjoint(Array(self.orderedMatchSets[0..<firstCycle]).map{matchSet in matchSet.restingPlayers}){
            print("first round not disjoint")
            return false
        }
        // then the average interval should be more than only a bit less than expected interval
        var restPlayersIndices=[Player:[Int]]()
        for (idx,matchSet) in self.orderedMatchSets.enumerated(){
            let restPlayers=matchSet.restingPlayers
            for player in restPlayers{
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

        
func partition_based_ordering(_ players:[Player], _ repeatedRestCounts:[Int], frequentResterIDs:Set<String>)->([String],[String]){
    assert(players.count>=sum(repeatedRestCounts))
        print("resting players being ordered...")
        let partitions=get_partitions_withIntegers_generative(players, repeatedRestCounts)
        var orderedPlayerKeys:[String]=[]
    var frequentResterKeys:[String]=[]
    for partition in partitions{//.shuffled(){
            for part in partition{
                if(!Set(part.map{player in player.id}).intersection(frequentResterIDs).isEmpty){frequentResterKeys.append(PlayerSet(part).id)}
                else if part.count==repeatedRestCounts[0]{
                    orderedPlayerKeys.append(PlayerSet(part).id)
                }
            }
        }
        return (orderedPlayerKeys,frequentResterKeys)
     
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


func get_partitions_withIntegers<T:Hashable>(_ orgList:[T],_ ints:[Int], setsToExclude:Set<Set<T>>=Set(), pruneQuotient:Int=0, doPotentiallyPrune:Bool, debug:Bool=false)-> [([[T]],[T])]{
    let doPrune=(!setsToExclude.isEmpty || doPotentiallyPrune)
    var partitionsWithRemainder:[([[T]],[T])]=[([],orgList)]//to be returned
    //assert(sum(ints)==orgList.count)
    let ints=ints.sorted()
    let intLen=ints.count
    var prevInt:Int=0
    var prevCombs=[[T]]()
    // this is for duplicate checking efficiency, we skip checking if the current int is the same as the last one
    //var sameAsPreviousInt=false
//    var isLastItem=false
    let remainderExists=(orgList.count != sum(ints) ? true : false)
    let lastInd=ints.count-1
    //    let myList=aList
    //    let needToFilter:Bool=duplicate_exists_inList(ints)
    for (cntr,currentInt) in ints.enumerated(){
        if(debug){print("partition index \(cntr) in \(ints) to be done...")}
        let isLastItem=(cntr==lastInd)
        let sameAsPreviousInt=(currentInt==prevInt)
        let lastSkip = !remainderExists && isLastItem && !sameAsPreviousInt
        let prevPartCnt=partitionsWithRemainder.count
//        let doPrune=(cntr != 0 && !isLastItem && partitions.count>50)
//        if(doPrune){print("pruning at the rate of \(pruneQuotient-1) / \(pruneQuotient)")}
        //we skip the last int comb gen if there's no remainder for efficiency
        if(lastSkip){if(debug){print("skipping last int extension")};partitionsWithRemainder=partitionsWithRemainder.map{(part,rem) in (part+[rem], [])} }else{
            partitionsWithRemainder=extend_partitions(partitionsWithRemainder, currentInt, setsToExclude:setsToExclude ,sameAsPreviousInt: sameAsPreviousInt, pruneQuotient: pruneQuotient, doPotentiallyPrune:doPotentiallyPrune, debug:debug)}
        if(debug){print("partitions now number \(partitionsWithRemainder.count) after \(cntr) extensions")}
        let remainderVariety=partitionsWithRemainder.map{(_part,rem) in Set(rem) }.reduce(Set()){$0.union($1)}
 //       assert(remainderVariety.count==orgList.count)
        prevInt=currentInt
        if(!isLastItem){assert(partitionsWithRemainder.count>prevPartCnt)}
    }
    if(!doPrune){
        assert(count_intpartitions(ints)==partitionsWithRemainder.count)
    }
    
    return partitionsWithRemainder
    
    
    func extend_partitions<U:Hashable>(_ partitionsWithRemainder:[([[U]],[U])],_ anInt:Int, setsToExclude:Set<Set<U>>, sameAsPreviousInt:Bool=false, pruneQuotient:Int, doPotentiallyPrune:Bool,debug:Bool=false)-> [([[U]],[U])]{
        var combsWithRemainder=[([[U]],[U])]()
        if(partitionsWithRemainder.count==1 && partitionsWithRemainder[0].0.isEmpty){
            for (comb,newRemainder) in combos_withRemainder(elements:Array(partitionsWithRemainder[0].1),k:anInt){
             //   let newRemainder=get_remainder(comb, superArray: partitionsWithRemainder[0].1)
                combsWithRemainder.append(([comb],newRemainder))
            }
            return combsWithRemainder
        }

        let partitionCount=partitionsWithRemainder.count
        let partCountTotal=partitionsWithRemainder[0].0.map{part in part.count}.reduce(0,+)
//        let remainingEls=baseElements.count-partCountTotal
        let remainderCount=partitionsWithRemainder[0].1.count
        let complexityScale=partitionCount*remainderCount
        let thresh=1000
        let doPrune=doPotentiallyPrune && (complexityScale>thresh ? true : false)
        
//        var newTupCands=[([[U]],[U])]()
//        let lastSkip =  (isLastItem && !sameAsLast)
//        let comboCount:Int? = (doPrune ? combo_count(n: baseElements.count, k: anInt) : nil)
        if(debug){print("complexity scale \(complexityScale)"+(complexityScale<thresh ? "": ", larger than the thresh \(thresh)"))}
        for (cntr,(orgPart,remainingElements)) in partitionsWithRemainder.enumerated(){
            if (cntr != 0 && cntr%500==0){if(debug){print("\(cntr) done")}}
                for (comboCntr,(comb,remainder)) in (doPrune ? randomly_generate_disjunct_combos(elements: remainingElements, k: anInt, proportionUpTo: 0.5) : combos_withRemainder(elements:Array(remainingElements),k:anInt)).enumerated(){
                    //if(complexityScale<=thresh && doPrune && comboCntr%pruneQuotient != 0){
                      //  continue}
                    if(!setsToExclude.isEmpty && setsToExclude.contains(Set(comb))){continue}
                    let candPart=orgPart+[comb]
                    let candPartWithRem=(candPart, get_remainder(comb, superArray: remainder))
                        if (!sameAsPreviousInt){
                            combsWithRemainder.append(candPartWithRem)
                        }else{
                            if (combsWithRemainder.filter{aPart in order_variants_partition(aPart.0,candPartWithRem.0)}.isEmpty){
                                combsWithRemainder.append(candPartWithRem)}else{if(debug){print("duplicate found")}}
                        }
                }
            
        }
            return combsWithRemainder
        }
        
    }

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
