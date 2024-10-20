//
//  ResultHistoryView.swift
//  goodMatches
//
//  Created by Yo Sato on 21/05/2024.
//

import SwiftUI

struct ResultHistoryView: View {
    @EnvironmentObject var  matchResults:MatchSetHistory
    var body: some View {
        List {
            ForEach(matchResults.results){matchSetResult in
                ForEach(matchSetResult.matchResults){matchResult in Text(matchResult.prettystring()+" (MatchSet  \(matchSetResult.matchSetInd!+1))")
                    
                }
                
            }
        }
    }
}

#Preview {
    ResultHistoryView()
}
