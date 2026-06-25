//
//  YouriBeaconSimulatorApp.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI
import SwiftData

@main
struct YouriBeaconSimulatorApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [BroadcastProject.self, BroadcastProject.self])
#if os(macOS)
				.frame(minWidth: 700)
				.frame(maxWidth: 1000)
#endif
		}
#if os(macOS)
		.windowResizability(.contentSize)
#endif
	}
}
