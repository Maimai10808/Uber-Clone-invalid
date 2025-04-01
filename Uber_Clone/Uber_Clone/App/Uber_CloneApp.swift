//
//  Uber_CloneApp.swift
//  Uber_Clone
//
//  Created by mac on 3/29/25.
//

import SwiftUI

@main
struct Uber_CloneApp: App {
    @StateObject var locationViewModel = LocationSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationViewModel)
        }
    }
}
