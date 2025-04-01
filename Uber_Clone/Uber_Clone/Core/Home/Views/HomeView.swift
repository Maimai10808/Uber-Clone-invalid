//
//  HomeView.swift
//  Uber_Clone
//
//  Created by mac on 3/29/25.
//

import SwiftUI

struct HomeView: View {
    @State private var mapState = MapViewState.noInput
    @State private var trip: Trip?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                UberMapViewRepresentable(mapState: $mapState, trip: $trip)
                    .ignoresSafeArea()
                
                if mapState == .searchingForLocation {
                    LocationSearchView(mapState: $mapState)
                } else if mapState == .noInput {
                    LocationSearchActivatiobView()
                        .padding(.top, 72)
                        .onTapGesture {
                            withAnimation(.spring) {
                                mapState = .searchingForLocation
                            }
                        }
                }
                
                MapViewActionButton(mapState: $mapState)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            
            if let trip = trip {
                RideRequestView(trip: trip)
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
#Preview {
    HomeView()
}
