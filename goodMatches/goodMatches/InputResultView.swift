//
//  InputResultView.swift
//  goodMatches
//
//  Created by Yo Sato on 17/04/2024.
//

import SwiftUI

struct InputResultView: View {
    @Environment(\.dismiss) var dismiss
    let matchSetInd:Int
    let sizedCourtCounts:[Int:Int]
    let match:Match
    @EnvironmentObject var matchResults:MatchResults
    @State var selection1:Int=0
    @State var selection2:Int=0
    @State var zeroAlertOn=false
    @State var duplicateAlertOn=true
    var body: some View {
        NavigationStack{
            VStack{
                MatchUp_sub(match:match)
                MultiPicker(selection1:$selection1, selection2:$selection2, values1:Array(0...6), values2:Array(0...6))
            }
            .toolbar{Button("Save"){
                let matchResult =
                get_matchresult(matchSetInd:matchSetInd,match:match,scores:(selection1,selection2))
                if(matchResult.scores==(0,0)){zeroAlertOn=true}else{
                    matchResults.add_matchResult(matchResult,sizedCourtCounts:sizedCourtCounts)
                    dismiss()
                }
            }.alert("0-0 is an invalid input",isPresented:$zeroAlertOn){
                Button("OK",role:.cancel){dismiss()}
            }
//            .alert(isPresented:$duplicateAlertOn){
//                
//                    Alert(
//                                    title: Text("We've had the same matchup, sure to add?"),
//                                    message: Text("results not added"),
//                                    primaryButton: .destructive(Text("")) {
//                                        
//                                    },
//                                    secondaryButton: .cancel()
//                                )
//                    
//                }
            }
        }
    }
}

//#Preview {
//    InputResultView()
//}
