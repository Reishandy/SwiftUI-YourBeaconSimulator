//
//  YouriBeaconSimulatorWatchApp.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

@main
struct YouriBeaconSimulatorWatch_Watch_AppApp: App {
	@State private var watchConnectivityService = WatchConnectivityService()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(watchConnectivityService)
        }
    }
}
