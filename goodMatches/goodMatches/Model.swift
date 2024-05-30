//
//  Model.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import Foundation

class MatchResults:ObservableObject{
    @Published var results=[MatchResult]()
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


enum Gender:String{
    case male="male"
    case female="female"
}

struct Player: Codable, Equatable, Hashable, Identifiable{
    enum CodingKeys:CodingKey{
        case name
        case score
        case gender
        case club
    }
    var name: String
    var score: Int
    var gender: String
    var club:String
    var id:String {name+"_"+club}

    mutating func update_score(_ increment: Int){
        self.score+=increment
    }
}

struct PlayerSet:Hashable,Equatable {
    let players:[Player]
    init(_ players:[Player]){
        self.players=players.sorted{$0.name<$1.name}
    }
}
struct Team:Hashable,Equatable,Identifiable {
    let players:[Player]
    var id:String
    var playerSet:Set<Player> {Set(self.players)}
    var scores:[Int] {players.map{$0.score}}
    var totalScore:Int {sum(scores)}
    var meanScore:Double {Double(self.totalScore/self.players.count)}
    init(_ players:[Player]){
        self.players=players.sorted{$0.name>$1.name}
        self.id=players.map{player in player.name}.joined(separator: "_")
    }
}

struct Match:Identifiable, Equatable, Hashable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.teams==rhs.teams
    }
    
    let teams:(Team,Team)
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
    var scoreDiff:Int {teams.0.totalScore-teams.1.totalScore/(teamsize==4 ? 1 : 2)}
    init(_ teams:[Team]) {
        let teamA=teams[0]; let teamB=teams[1]
        let team1:Team;let team2:Team
        if(teamA.totalScore>teamB.totalScore){team1=teamA;team2=teamB}else{
            team1=teamB;team2=teamA
        }
        self.teams=(team1,team2)
        self.id=[teamA.id,teamB.id].sorted{$0<$1}.joined(separator:":")
    }
}



class PlayersOnCourt:ObservableObject{
    @Published var players:[Player]=[]
    var sortedPlayers:[Player] {players.sorted(by:{$0.score>$1.score})}
    var sortedScores:[Int] {sortedPlayers.map{$0.score}}
    var maxScore:Int {sortedScores.max() ?? 100}
    var minScore:Int {sortedScores.min() ?? 0}
    var mean:Double {Double(sum(sortedScores)/sortedScores.count)}
    var stddev:Double {goodMatches.stddev(nums:sortedScores.map{Double($0)},mean:mean)}
    var thresholds:(Double,Double) {(self.mean+self.stddev,self.mean-self.stddev)}
    var classifiedTeams:[Int:[String:[Team]]] {
        var myDict:[Int:[String:[Team]]]=[1:["s":[],"m":[],"w":[]],2:["s":[],"m":[],"w":[]]]
        for n in 1...2{
            for playerSet in goodMatches.combos(elements:self.sortedPlayers,k:n){
                if (playerSet.count==2 && playerSet[0]==playerSet[1]){continue}
                let aTeam=Team(playerSet)
                let combinedStrengthUnsorted=self.get_relativestrength_team(aTeam)
                let combinedStrength=String(combinedStrengthUnsorted.sorted())
                myDict[n]![combinedStrength]!.append(aTeam)
            }}
        return myDict
    }
    
    func get_balanced_matches(_ perCourtPlayerCounts:[Int])-> [Int:[PlayerSet:[Match]]]{
        let orderedLevelCombos=[["s","s"],["m","m"],["w","w"],["m","s"],["m","w"],["s","w"]]
        
        var sizedTeamedMatches=[Int:[PlayerSet:[Match]]]()
        for perCourtPlayerCount in perCourtPlayerCounts {
            sizedTeamedMatches[perCourtPlayerCount]=[:]
        }
        for perCourtPlayerCount in perCourtPlayerCounts{
            //            var teamedMatchesPerTeamsize=[PlayerSet:[Match]]()
            //            var oppositionPairsToAdd=[[Team]]()
            for levelCombo in orderedLevelCombos{
                //              if(oppositionPairsToAdd.count>500){break}
                let teamSet1:[Team]=classifiedTeams[perCourtPlayerCount/2]![levelCombo[0]]!
                let teamSet2:[Team]=classifiedTeams[perCourtPlayerCount/2]![levelCombo[1]]!;                if((teamSet1.isEmpty||teamSet2.isEmpty)){continue}
                
                var oppositionPairsToAdd=[[Team]]()
                if(levelCombo[0]==levelCombo[1]){
                    oppositionPairsToAdd=combos(elements:teamSet1,k:2)
                    oppositionPairsToAdd=oppositionPairsToAdd.filter{ teams_nooverlap_p($0) }
                } else{
                    oppositionPairsToAdd=product(teamSet1,teamSet2)
                    oppositionPairsToAdd=oppositionPairsToAdd.filter{ teams_nooverlap_p($0) }
                }
                for teams in oppositionPairsToAdd{
                    let playerSet=PlayerSet(teams[0].players+teams[1].players)
                    let match=Match(teams)
                    if let _teamedMatches = sizedTeamedMatches[perCourtPlayerCount]![playerSet]{
                        sizedTeamedMatches[perCourtPlayerCount]![playerSet]!.append(match)}else{sizedTeamedMatches[perCourtPlayerCount]![playerSet]=[match]}
                }
            }
        }
        return sizedTeamedMatches
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
    
    func update_score(_ result:MatchResult){
//        let winningTeam=result.winningTeam
  //      let losingTeam=result.losingTeam
    //    let scores=result.scores
        if(result.drawnP){
            return
        }
        let winningTeam=(result.scores.0>result.scores.1 ? result.match.teams.0 : result.match.teams.1)
        let losingTeam=(result.scores.0>result.scores.1 ? result.match.teams.1 : result.match.teams.0)
        
        let increment=get_elo_update_value(winningTeam:winningTeam,against:losingTeam,result:result.scores)
            
        for winningPlayer in winningTeam.players{
            let ind=playerInd_fromID(winningPlayer.id)
            self.players[ind].score+=Int(increment)
        }
        for losingPlayer in losingTeam.players{
            let ind=playerInd_fromID(losingPlayer.id)
            self.players[ind].score-=Int(increment)
        }

    }
    

    func update_scores(_ results:[MatchResult]){
        for matchResult in results{
            self.update_score(matchResult)
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
struct MatchSetOnCourt:Hashable{
    let sizedMatchesOnCourt:[Int:[Match]]
    let sizedCourtCounts:[Int:Int]
    var matchesOnCourt:[Match] {(sizedMatchesOnCourt[4] ?? [])+(sizedMatchesOnCourt[2] ?? [])}
    var allTeamOppositions:[(Team,Team)] {matchesOnCourt.map{$0.teams}}
    var playingPlayers:[Player] {matchesOnCourt.map{match in match.listOfPlayers}.flatMap{$0}}
    var restingPlayers=[Player]()
    var allPlayers:[Player] {playingPlayers+restingPlayers}
    var playingRestingPlayerCounts:(Int,Int) {(self.playingPlayers.count, self.restingPlayers.count)}
    
    func hash(into hasher: inout Hasher){
        hasher.combine([sizedMatchesOnCourt])
    }

    var sizedScoreDiffs:[Int:Double] {
        let myTuple=self.sizedMatchesOnCourt.map { (size,matches) in
            return (size, Double(matches.map{match in match.scoreDiff}.reduce(0,+))/Double(sizedMatchesOnCourt[size]!.count))
        }
        return Dictionary(uniqueKeysWithValues: myTuple)
    }
    var sizedWeights:[Int:Double] {
        return intDict2weightDict(sizedCourtCounts)
    }
    var totalScoreDiff:Double {
        let sizedScoreDiffsT=sizedMatchesOnCourt.map{ (size,matches) in (size, matches.map{ match in Double(match.scoreDiff) } )  }
        let sizedTotalScoreT=sizedScoreDiffsT.map{ (size,scoreDiffs) in (size, scoreDiffs.reduce(0,+)/sizedWeights[size]!) }
        return Dictionary(uniqueKeysWithValues: sizedTotalScoreT).values.reduce(0,+)
    }
    
//    init(_ teamSets:[[Team]], _ restingPlayers:[Player]) {
  //      let matches=teamSets.map{Match($0)}
    //    self.matchesOnCourt=matches
      //  self.restingPlayers=restingPlayersflet
    //}
    
    init(_ sizedMatches:[Int:[Match]], sizedCourtCounts:[Int:Int], restingPlayers:[Player]=[]){
        self.sizedMatchesOnCourt=sizedMatches
        self.restingPlayers=restingPlayers
        self.sizedCourtCounts=sizedCourtCounts
        
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

func shared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt, shareFnc:(MatchSetOnCourt,MatchSetOnCourt)->Double?)->Bool{
    assert(aMatchSet.sizedCourtCounts==anotherMatchSet.sizedCourtCounts)
    return shareFnc(aMatchSet, anotherMatchSet) != 0
}

func singlesPlayerShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert(aMatchSet.sizedCourtCounts.keys.contains(2))
    return shared_p(aMatchSet,anotherMatchSet,shareFnc:singlesPlayerShare_rate)
}
func singlesPlayerNotShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert(aMatchSet.sizedCourtCounts.keys.contains(2))
    return !shared_p(aMatchSet,anotherMatchSet,shareFnc:singlesPlayerShare_rate)
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
    return shared_p(aMatchSet, anotherMatchSet, shareFnc:doublesTeamShare_rate)
    
}
func doublesTeamNotShared_p(_ aMatchSet:MatchSetOnCourt, _ anotherMatchSet:MatchSetOnCourt)->Bool{
    assert (aMatchSet.sizedCourtCounts.keys.contains(4))
    return !shared_p(aMatchSet, anotherMatchSet, shareFnc:doublesTeamShare_rate)
    
}

func matchset_duplicate_p(_ matchSets:[MatchSetOnCourt])->Bool{
    let matchCount=matchSets.count
    for (idx,currentMS) in matchSets.enumerated(){
        for anotherMS in matchSets[0..<idx]+matchSets[idx+1..<matchCount]{
            if currentMS.match_identical(anotherMS){
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
    var players:[Player] { self.orderedMatchSets[0].playingPlayers }
    var sizedCourtCount:[Int:Int] {self.orderedMatchSets[0].sizedCourtCounts}
    var doublesSinglesPs:(Bool,Bool) {(self.sizedCourtCount.keys.contains(4),self.sizedCourtCount.keys.contains(2))}
    
    
    func all_share_players()->Bool{
        return true
    }


    // THIS IS THE MAIN FUNC
    func get_best_matchsets(_ playersOnCourt:PlayersOnCourt, _ courtCount:Int){
        let teamsizedCourtCount=assign_courtTeamsize(courtCount: courtCount, playerCount: playersOnCourt.players.count)
        // get possible balanced pairs, doubles / singles
        print("initial matchsets...")
        let sizeTeamKeyedMatches=playersOnCourt.get_balanced_matches(Array(teamsizedCourtCount.keys))
        print("...prepared")

        // get all matchsets, resting-player 'team' classified
        print("getting possible combinations...")

        let goodMatchSets=get_good_matchsets(teamsizedCourtCount, sizeTeamKeyedMatches, playersOnCourt.players)
        //assert(!matchset_duplicate_p(goodMatchSets))
        print("... worked out")

        // filtering
//        let goodMatchSets=filter_matchsets(courtTeamsizeAssignments, combosOfTeamPairsOfCourtCount, playersOnCourt)
        
        // ordering
        print("ordering...")
        self.orderedMatchSets=order_matchsets(goodMatchSets)
       // assert(!matchset_duplicate_p(orderedGoodMatchSets))
        print("...done")
        
//        let finalMatchSets=apply_intermatchset_constraints(orderedGoodMatchSets,firstPart:6)
        
//        self.orderedMatchSets=finalMatchSets
        self.courtCount=courtCount
        
    }
    
    func get_good_matchsets(_ sizedCourtCounts:[Int:Int], _ sizeTeamKeyedMatches:[Int:[PlayerSet:[Match]]], _ players:[Player])->[MatchSetOnCourt]{
        // to be returned, a matchSetOnCourt is a set of player-exclusive matches happening at a time on multiple courts
        // flat list of matchSetOnCourts will be returned, with the concurrent match count length
        var matchSetsOnCourt=[MatchSetOnCourt]()
        // e.g. for 12 people with 4 courts, we'll have 2singlesx2 + 2doublesx4 = 12. Each element, i.e. a matchSetCourt, will consist of four matches, 2 singles, 2 doubles
                
        // the trick for efficiency is to first prepare player-exclusive combinations
        // e.g. for {2:2,4:2} (2 singles, 2 doubles) with 12 players p1...p10, we prepare possible combos like Match(p1 v p2), M(p3 v p4), M((p5,p6)v(p7,p8)) and M((p9,p10)v(p11,p12))
        
        var ints=[Int]()
        for (size,count) in sizedCourtCounts{
            ints+=Array(repeating:size,count:count)
        }
        
        let playerPartitions=get_partitions_withIntegers(players,ints)
        let haveRestingPlayers:Bool=(players.count==sum(ints) ? false : true)
        // a player partition is a court-count numbered set of mutually excl. player sets e.g. ((p1,p2),(p3,p4),(p5,p6,p7,p8),(p9,p10,p11,p12)) for four courts
        for playerPartition in playerPartitions{
            let possibleMatchSets=get_balancedMatches(playerPartition,sizeTeamKeyedMatches)
            if (!possibleMatchSets.isEmpty){
                for possibleMatchSet in possibleMatchSets{
                    let playingPlayers=possibleMatchSet.map{match in match.listOfPlayers}.flatMap{$0}
                    let restingPlayers:[Player]=(haveRestingPlayers ? players.filter{player in !playingPlayers.contains(player)} : [])
                    matchSetsOnCourt.append(MatchSetOnCourt(possibleMatchSet,restingPlayers: restingPlayers))
                }
            }
        }
        return matchSetsOnCourt
        
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
        
    func order_matchsets(_ matchSets:[MatchSetOnCourt])-> [MatchSetOnCourt] {
        let orgCount=matchSets.count
        //stuff to return
        var orderedGoodMatchSets=[MatchSetOnCourt]()
        
        let ourMatchSets=( matchSets.count>20000 ? Array(matchSets[0..<20000]) : matchSets)
        
        let players=ourMatchSets[0].playingPlayers+ourMatchSets[0].restingPlayers

        // temporarily team-classifying to enable restingplayer-based ordering
        var restPlayerKeyedMatchSets:[PlayerSet:[MatchSetOnCourt]]=[:]
        let playingRestingPlayerCounts=ourMatchSets[0].playingRestingPlayerCounts
        for matchSet in ourMatchSets{
            let restingPlayers=PlayerSet(matchSet.restingPlayers)
            if let matches=restPlayerKeyedMatchSets[restingPlayers]{
                restPlayerKeyedMatchSets[restingPlayers]!.append(matchSet)}else{
                    restPlayerKeyedMatchSets[restingPlayers]=[matchSet]
                }
        }
        
        let tip=(orgCount>28 ? 7 : orgCount/3)
        let window=tip/2
        
        // then sort each keyed sets
        for (restSet, matchSetsPerRestSet) in restPlayerKeyedMatchSets{
            let matchSetsPerRestset=restPlayerKeyedMatchSets[restSet]!
            restPlayerKeyedMatchSets[restSet]=matchSetsPerRestset.sorted{$0.totalScoreDiff < $1.totalScoreDiff}
        }
        orderedGoodMatchSets=get_zipped_sequences(restPlayerKeyedMatchSets,playingRestingPlayerCounts,players,constraintTipWindow: (tip,window))
        return orderedGoodMatchSets
    }
    
    // checking methods
    func intermatchset_constraints_observed(tipWindow:(Int,Int))->Bool{
        var myBool:Bool
        var fncs=[(MatchSetOnCourt,MatchSetOnCourt)->Bool]()
        if(self.doublesSinglesPs.0){fncs.append(doublesTeamNotShared_p)}
        if(self.doublesSinglesPs.1){fncs.append(singlesPlayerNotShared_p)}
        let tip=tipWindow.0; let window=tipWindow.1
        for ind in (window..<tip){
            let histMatchSets=Array(self.orderedMatchSets[ind-window..<ind])
            myBool=satisfy_allconstraints_allmatchsets(self.orderedMatchSets[ind], histMatchSets: histMatchSets, fncs: fncs)
            if !myBool{return false}
        }
        return true
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

func get_zipped_sequences(_ aDict:[PlayerSet:[MatchSetOnCourt]], _ totalRestingPlayerCounts:(Int,Int), _ players:[Player], constraintTipWindow:(Int,Int))->[MatchSetOnCourt]{
    let repetitionCount:Int=(totalRestingPlayerCounts.1==0 ? 1 : totalRestingPlayerCounts.0/totalRestingPlayerCounts.1)
    let playingCount=totalRestingPlayerCounts.0
    let restCount=totalRestingPlayerCounts.1
    let totalCount=playingCount+restCount
    let (firstPart,histWindow)=constraintTipWindow
    var orderedKeys=(restCount==0 ? Array(aDict.keys) : partition_based_ordering(players,Array(repeating:restCount,count:totalCount/restCount)))
    let orderedKeyCount=orderedKeys.count
    var myDict=aDict
    var orderedMatchSets=[MatchSetOnCourt]()
    var iterations=0
    while(!myDict.values.reduce([]){$0+$1}.isEmpty){
        if(iterations>=1){orderedKeys=orderedKeys.shuffled()}
        for (cntr,key) in orderedKeys.enumerated(){
            let currentCount=orderedMatchSets.count
            var matchSets=myDict[key]!
            let ind:Int
            if !matchSets.isEmpty{
                if(currentCount<=firstPart){
                    let historyStartInd=(currentCount>histWindow ? currentCount-histWindow : 0)
                    ind=(get_next_good_ind(matchSets, histMatchSets:Array(orderedMatchSets[historyStartInd...])) ?? 0)
                }else{
                    ind=0
                }
                let extracted=matchSets.remove(at:ind)
                myDict[key]=matchSets
                orderedMatchSets.append(extracted)
            }
        }
        iterations+=1
        if (iterations>50){break}
    }
        return orderedMatchSets
    }
        
func partition_based_ordering(_ players:[Player], _ repeatedRestCounts:[Int])->[PlayerSet]{
        print("resting players being ordered...")
        let partitions=get_partitions_withIntegers_generative(players, repeatedRestCounts)
        var orderedPlayerKeys=[PlayerSet]()
        
        for partition in partitions.shuffled(){
            for part in partition{
                if part.count==repeatedRestCounts[0]{
                    orderedPlayerKeys.append(PlayerSet(part))
                }
            }
        }
        return orderedPlayerKeys
        
    }
        
func get_next_good_ind(_ matchSets:[MatchSetOnCourt], histMatchSets:[MatchSetOnCourt], from:Int=0)->Int?{
    var fncs=[(MatchSetOnCourt,MatchSetOnCourt)->Bool]()
    if matchSets[0].sizedCourtCounts.keys.contains(2){fncs.append(singlesPlayerNotShared_p)}
    if matchSets[0].sizedCourtCounts.keys.contains(4){fncs.append(doublesTeamNotShared_p)}
    for (cntr, matchSet) in matchSets[from...].enumerated(){
        if satisfy_allconstraints_allmatchsets(matchSet,histMatchSets:histMatchSets,fncs:fncs){
            return from+cntr
        }
    }
    return nil
}

func satisfy_allconstraints_allmatchsets(_ matchSet:MatchSetOnCourt, histMatchSets:[MatchSetOnCourt], fncs:[(MatchSetOnCourt,MatchSetOnCourt)->Bool])->Bool{
    for histMatchSet in histMatchSets{
        for fnc in fncs{
            if !fnc(matchSet,histMatchSet){
                return false
            }
        }
    }
    return true
}

func get_partitions_withIntegers_generative<T:Hashable>(_ myList:[T],_ ints:[Int], stopCount:Int=10)-> [[[T]]]{
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


func get_partitions_withIntegers<T:Hashable>(_ myList:[T],_ ints:[Int])-> [[[T]]]{
    var partitions=[[[T]]]()
    //    assert(sum(ints)==aList.count)
    let ints=ints.sorted()
    let intLen=ints.count
    var prevInt:Int=0
    var prevCombs=[[T]]()
    var sameAsLast=false
    var lastItem=false
    let remainderExists=(myList.count != sum(ints) ? true : false)
    
    //    let myList=aList
    //    let needToFilter:Bool=duplicate_exists_inList(ints)
    for (cntr,myInt) in ints.enumerated(){
        print("partition \(cntr+1) out of \(intLen) being done")
        sameAsLast=(prevInt==myInt)
        lastItem=(cntr==ints.count-1)
        let combs=(sameAsLast ? prevCombs : combos(elements:myList,k:myInt))
        //        if (cntr+1<intLen && ints[cntr+1]==myInt){
        //            combs=combs.filter{el in el[0]==1}
        //        }
        prevInt=myInt
        prevCombs=combs
        if cntr==0{
            partitions+=combs.map{comb in [comb]}
            continue
        }
        partitions=extend_product(partitions,combs,myList,myInt,sameAsLast:sameAsLast,lastItem:lastItem,remainderExists:remainderExists)
        //        if needToFilter{
        //            parts=filter_order_variant_partitions(parts)
        //        }
    }
    
    return partitions
    
    
    func extend_product<U:Hashable>(_ cumProducts:[[[U]]],_ combs:[[U]],_ base:[U],_ anInt:Int, sameAsLast:Bool=false, lastItem:Bool=false, remainderExists:Bool=false)-> [[[U]]]{
        var newTupCands=[[[U]]]()
        let count=cumProducts.count
        let many=count>5000
        let lastSkip = (!remainderExists && lastItem && !sameAsLast)
        for (cntr,orgArrays) in cumProducts.enumerated(){
            if (count>1000 && cntr != 0 && cntr%1000==0){print("\(cntr) out of \(count)")}
            if (!lastSkip && many && cntr%4 != 0){
                if cntr==0{print("will do some random pruning")}
                continue
            }
            let genUnion=orgArrays.reduce(Set()){Set($0).union(Set($1))}
            let complement=base.filter{el in !genUnion.contains(el)}
            if(lastSkip){
                let cand:[[U]]=orgArrays+[complement]
                newTupCands.append(cand)
            }else{
                for comb in combos(elements:complement,k:anInt){
                    let cand:[[U]]=orgArrays+[comb]
                    if !newTupCands.contains(cand){
                        if (!sameAsLast){
                            newTupCands.append(cand)
                        }else{
                            if (newTupCands.filter{aPart in order_variants_partition(aPart,cand)}.isEmpty){
                                newTupCands.append(cand)}//else{print("duplicate found")}
                        }
                        //else{print("skipped due to dup")}
                    }
                }
            }
        }
            return newTupCands
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

