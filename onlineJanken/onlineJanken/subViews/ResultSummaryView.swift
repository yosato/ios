//
//  ResultSummaryView.swift
//  onlineJanken
//
//  Created by Yo Sato on 17/09/2024.
//

import SwiftUI
import jankenModels

struct ResultSummaryView: View {
    @EnvironmentObject var series:JankenSeriesInGroup
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                ForEach(Array(zip(series.seriesTree.sortedLeaves.indices, series.seriesTree.sortedLeaves)),id:\.0){(ind, participant) in
                    Text("\(ind+1)位 \(participant.displayName)").font((ind==0 ? .title : .body))
                }
            }.navigationTitle("総合結果").navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement:.bottomBar){
                        NavigationLink("詳しく見る"){SeriesResultViewStatic()}
                    }   
                    ToolbarItem(placement:.bottomBar){
                        Button("閉じる"){dismiss()}
                    }
                }
                
            }
            
        }
                  
        
    }
    
    
    


#Preview {
    SeriesResultView()
   // ResultSummaryView().environmentObject(JankenSeriesInGroup())
}
