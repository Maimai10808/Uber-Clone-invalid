//
//  LocationSearchView.swift
//  Uber_Clone
//
//  Created by mac on 3/29/25.
//

import SwiftUI

struct LocationSearchView: View {
    @State private var startLocationText = ""
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @Binding var mapState: MapViewState
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // header view
            HStack {
                VStack {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 24)
                    
                    Circle()
                        .fill(.black)
                        .frame(width: 6, height: 6)
                }
              
                VStack {
                    TextField("Current location", text: $startLocationText)
                        .frame(height: 32)
                        .background(Color(.systemGroupedBackground))
                        .padding(.trailing)
                    
                    TextField("Where to?", text: $locationViewModel.queryFragment)
                        .frame(height: 32)
                        .background(Color(.systemGray4))
                        .padding(.trailing)
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 64)
            
            Divider()
                .padding(.vertical)
            
            // list view
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(locationViewModel.searchResults, id: \.self) { result in
                        LocationSearchResultCellView(title: result.title, subtitle: result.subtitle)
                            .onTapGesture {
                                locationViewModel.selectLocation(result)
                                withAnimation(.spring) {
                                    mapState = .locationSelected
                                }
                            }
                    }
                }
            }
        }
        .background(.white)
    }
}
