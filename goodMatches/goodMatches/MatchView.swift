//
//  MatchView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI


struct MatchView: View {
    let liveMode: Bool
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets:GoodMatchSetsOnCourt
    @EnvironmentObject var matchResults:MatchSetHistory
    @State var currentMatchSetInd:Int=0
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
    
    @State var gainsLosses:[((Team,Team),Double)]=[]
    @State private var showGains=false
    
    var debug:Bool

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
                        Text("goodMatch \(matchSetInd+1)"+(!debug ? "" : "  "+String(format:"%.2f",matchSet.totalScoreDiff)))
                        MatchUp(matchSetInd: matchSetInd, debug:debug)
                        if (matchSet.restingPlayerSet.players.count != 0){
                            HStack{
                                Text("Resting: ").font(.headline.smallCaps())
                                ForEach(matchSet.restingPlayerSet.players, id:\.self){Text($0.name)}
                            }
                        }
                    }.brightness(matchSetInd==currentMatchSetInd ? 0 : 0.5).padding()              .overlay(RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color(uiColor: (matchSetInd==currentMatchSetInd ? .green : .tertiaryLabel)), lineWidth: 3))
                    
                }.listRowInsets(EdgeInsets())//outer foreach
                
            }.listStyle(InsetGroupedListStyle()).ignoresSafeArea()//list
            Button(action:{
                if(liveMode){
                    gainsLosses=myPlayers.update_playerscores_matchSetResult(matchResults.results.first!)
                    showGains=true
                    goodMatchSets.update_matchsets_onResult()
                    Task{await myPlayers.update_playerscores_remote(urlStr:"http://satoama.co.uk:5000/players")}
                }
                currentMatchSetInd=(currentMatchSetInd+1<comboCount ? currentMatchSetInd+1 : 0)
                
            },label:{Text(liveMode ? "Update and go next" : "Next Match")}).padding().disabled(liveMode && (matchResults.results.count < currentMatchSetInd+1 || !matchResults.results.last!.completed))
        }.alert("\(gainsLosses2string(gainsLosses))",isPresented:$showGains){}
        
    }
    func gainsLosses2string(_ gainsLosses:[((Team,Team),Double)])->String{
        var messages:[String]=[]
        for ((team,_),gain) in gainsLosses{
            messages.append(team.players.map{player in player.name}.joined(separator:"/")+" gained "+String(format:"%.2f",gain)+" points"+(team.players.count==2 ? " each" : ""))
        }
        return messages.joined(separator:"\n")
    }
}


struct MatchUp:View{
    let matchSetInd:Int
    //    let matchSet:[Match]
    @EnvironmentObject var goodMatchSets:GoodMatchSetsOnCourt
    var matchSetOnCourt:MatchSetOnCourt {goodMatchSets.orderedMatchSets[matchSetInd]}
    var matchSet:[Match] { matchSetOnCourt.matchesOnCourt }
    @EnvironmentObject var matchSetHistory:MatchSetHistory
    @State var currentMatch:Match? = nil
    @State var matchInd:Int=0
    var debug:Bool
    @State var resultInputs:[(Int,Int)]=[]
    @State var hasAppeared:Bool=false
//    @State var stuff0:[Int]
//    init(){
//        self.stuff=Array(repeating:(0,0),count:goodMatchSets.orderedMatchSets[matchSetInd].matchesOnCourt.count)
//    }

    var body: some View{
        VStack{
        NavigationStack{

                ForEach(Array(zip(matchSet.indices,matchSet)),id:\.0){ (index, match) in
                    let team1=match.teams.0
                    let team2=match.teams.1
                    let isDoubles=(team1.players.count==2 ? true : false)
                    HStack(alignment: .top){    Text((isDoubles ? "D" : "S")).font(.headline.smallCaps()).padding()
                        Spacer()
                        VStack{
                            HStack{
                                VStack{ForEach(match.pairOfPlayers.0,id:\.self){Text($0.name+(!debug ? "" : " \($0.score)"))}}
                                Spacer()
                                Text("vs")
                                Spacer()
                                VStack{ForEach(match.pairOfPlayers.1,id:\.self){Text($0.name+(!debug ? "" : " \($0.score)"))}}
                                if(debug){Text(String(format:"%.2f",match.scoreDiff))}
                            }
                            HStack{
                                Spacer()
                                HStack{
                                    if(!resultInputs.isEmpty){
                                        Spacer()
                                        Picker("",selection:$resultInputs[index].0){
                                            if(resultInputs[index].1==6||resultInputs[index].1==5){ForEach(0..<8){Text("\($0)")}}else{ForEach(0..<7){Text("\($0)")}}
                                        }.frame(width:60).pickerStyle(WheelPickerStyle())
                                        Spacer()
                                        Picker("",selection:$resultInputs[index].1){
                                            if(resultInputs[index].0==6||resultInputs[index].0==5){ForEach(0..<8){Text("\($0)")}}else{ForEach(0..<7){Text("\($0)")}}
                                        }.frame(width:60).pickerStyle(WheelPickerStyle())
                                        Spacer()
                                    }
                                }.frame(height:40)
                                if (!matchSetHistory.results.isEmpty){
                                    let matchID=match.id+"__"+String(matchSetInd)
                                    if let matchResult=matchSetHistory.get_first_matchResult_byMatchID(matchID){
                                        Text("\(matchResult.scores.0)-\(matchResult.scores.1)")
                                    }
                                }
                            }
                        }
                    }
                }
            if(matchSetInd==goodMatchSets.orderedMatchSets.count-1){
                Button("Save/correct results"){
                    var matchResults=[MatchResult]()
                    for (cntr,result) in resultInputs.enumerated(){
                        matchResults.append(get_matchresult(matchSetInd: matchSetInd, match: matchSet[cntr], scores: result))
                    }
                    let matchSetResult=MatchSetResult(matchResults:matchResults)
                    matchSetHistory.add_replace_matchSetResult(matchSetResult,sizedCourtCounts:matchSetOnCourt.sizedCourtCounts)
                    
                }.disabled(both_zero_exists(resultInputs))
            }
            }
        }.onAppear{
            guard !hasAppeared else {return}
            resultInputs=Array(repeating:(0,0),count:matchSet.count)
            hasAppeared=true
            print(resultInputs)
        }
//        .sheet(item:$currentMatch){aMatch in
//            InputResultView(matchSetInd:matchSetInd, sizedCourtCounts:matchSetOnCourt.sizedCourtCounts, match:matchSet[matchInd]).environmentObject(matchResults)
//        }
//        .sheet(isPresented:$showInputResult){
//            
//            //InputResultView(matchSetInd:matchSetInd, sizedCourtCounts:matchSetOnCourt.sizedCourtCounts, match:matchSet[0]).environmentObject(matchResults)
//            InputResultView(matchSetInd:matchSetInd, sizedCourtCounts:matchSetOnCourt.sizedCourtCounts, match:matchSet[0]).environmentObject(matchResults)
//        }

    }//NavStack
    func both_zero_exists(_ resultInputs:[(Int,Int)])->Bool{
        for (int1,int2) in resultInputs{
            if(int1 == 0 && int2 == 0){return true}
        }
        return false
    }
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
    MatchView(liveMode:true,debug:false).environmentObject(PlayersOnCourt()).environmentObject(GoodMatchSetsOnCourt())
        .environmentObject(MatchSetHistory())
}
