//
//  MatchView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI


struct MatchView: View {
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets:GoodMatchSetsOnCourt
    @State var currentMatchSetInd:Int=0
//    @State var results=[((Team,Team),(Int,Int))]()
//    @State var resultDict=[Team:Int]()
//    @State var resultDict0:[Int:Int]=[0:0]
//    @State var matchResultsD=[Int:MatchResult]()
    @StateObject var matchResults=MatchResults()
    @State var result:Int=0
    var values1d:[Int]=Array(0...6)
    var values2d:[Int]=Array(0...6)
    @State var selection3d:[Int:Int]=[0:0]
    @State var selection1d:Int=0
    @State var selection2d:Int=0
    var values1s:[Int]=Array(0...6)
    var values2s:[Int]=Array(0...6)
    @State var selection1s:Int=0
    @State var selection2s:Int=0
    @State private var showInputResult=false

    var bestMatchSetsOnCourt:[MatchSetOnCourt] {
        Array(goodMatchSets.orderedMatchSets[0...currentMatchSetInd]).reversed()
    }
    
    var indexedBestMatchSetsOnCourt:[(Int,MatchSetOnCourt)] {
        Array(zip((0...currentMatchSetInd).reversed(), bestMatchSetsOnCourt))
    }
    
    var comboCount:Int {goodMatchSets.orderedMatchSets.count}

        
    private func binding(for key: Int) -> Binding<Int> {
        return .init(
            get: { self.selection3d[key, default: 0] },
            set: { self.selection3d[key] = $0 })
    }
    
    
    var body: some View {
        VStack{
            List{
                ForEach(indexedBestMatchSetsOnCourt,id:\.1){ (matchSetInd, matchSet) in
                    VStack{
                        Text("MatchSet \(matchSetInd+1)")
                        MatchUp(matchSetInd: matchSetInd, matchResults: matchResults)
                        if (matchSet.restingPlayers.count != 0){
                            HStack{
                                Text("Resting: ").font(.headline.smallCaps())
                                ForEach(matchSet.restingPlayers, id:\.self){Text($0.name)}
                            }
                        }
                    }.brightness(matchSetInd==currentMatchSetInd ? 0 : 0.5).padding()              .overlay(RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color(uiColor: (matchSetInd==currentMatchSetInd ? .green : .tertiaryLabel)), lineWidth: 3))
                    
                }.listRowInsets(EdgeInsets())//outer foreach
                
            }.listStyle(InsetGroupedListStyle()).ignoresSafeArea()//list
            Button(action:{
                myPlayers.update_scores(Array(matchResults.results))
                
                currentMatchSetInd=(currentMatchSetInd+1<comboCount ? currentMatchSetInd+1 : 0)
                
            },label:{Text("Next match")})
            Text("There are \(comboCount) combinations (currently no. \(currentMatchSetInd+1))")
        }
    }
    
}


struct MatchUp:View{
    let matchSetInd:Int
    //    let matchSet:[Match]
    @EnvironmentObject var goodMatchSets:GoodMatchSetsOnCourt
    var matchSet:[Match] { goodMatchSets.orderedMatchSets[matchSetInd].matchesOnCourt }
    @ObservedObject var matchResults:MatchResults
    @State var currentMatch:Match? = nil
    @State var matchInd:Int=0
    //        @State var showInputResult=false
    
    var body: some View{
        NavigationStack{
            ForEach(Array(zip(matchSet.indices,matchSet)),id:\.0){ (index, match) in
                let team1=match.teams.0
                let team2=match.teams.1
                let isDoubles=(team1.players.count==2 ? true : false)
                HStack(alignment: .top){    Text((isDoubles ? "D" : "S")).font(.headline.smallCaps()).padding(0.5)
                    
                    VStack{
                        MatchUp_sub(match:match).padding()
                        HStack{
                            Spacer()
                            if (!matchResults.results.isEmpty){
                                //                                    let teamsScores=matchResults.get_result_byID([team1,team2])
                                //                                    if !teamsScores.isEmpty{
                                //                                        Text("\(teamsScores[team1]!)-\(teamsScores[team2]!)")
                            }
                        }
                        Spacer()
                        Button("Input/correct result"){
                            //showInputResult=true
                            currentMatch=match
                            matchInd=index
                        }
                    }
                }
            }
            
            .sheet(item:$currentMatch){aMatch in
                InputResultView(matchSetInd:matchSetInd, match:matchSet[matchInd])
            }
        }//ForEach
        
    }//NavStack
    
}


struct MatchUp_sub:View{
    let match:Match
    var body: some View{
            HStack{

                VStack{ForEach(match.pairOfPlayers.0,id:\.self){Text($0.name)}
                }
                
                
                Spacer()
                Text("vs")
                Spacer()
                VStack{ForEach(match.pairOfPlayers.1,id:\.self){Text($0.name)}}
            }
        
        }
}



#Preview {
    MatchView().environmentObject(PlayersOnCourt()).environmentObject(GoodMatchSetsOnCourt())
}
