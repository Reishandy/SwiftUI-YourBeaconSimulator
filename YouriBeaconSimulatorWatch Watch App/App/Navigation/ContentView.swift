//
//  ContentView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

struct ContentView: View {
	// TODO: Remember this only mirrors
    var body: some View {
		NavigationStack {
			// TODO: Error toeast
			if WatchConnectivityService.shared.phoneState?.isForeground == true {
				// TODO: Nav
				List {
					if WatchConnectivityService.shared.showFailureToast {
						Label("Command failed", systemImage: "exclamationmark.triangle")
							.font(.caption2)
							.padding(6)
							.background(.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
					}
					
					Text(WatchConnectivityService.shared.phoneState?.broadcastingBeaconID?.uuidString ?? "")
					Text(WatchConnectivityService.shared.phoneState?.isDiscovering ?? false ? "true" : "false")
					
//					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Broadcast",
							systemImage: "sensor.radiowaves.left.and.right.fill"
						)
						.onTapGesture {
							WatchConnectivityService.shared.send(.startBroadcast(beaconID: UUID()))
						}
//					}
					
//					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Discover",
							systemImage: "dot.radiowaves.up.forward"
						)
						.onTapGesture {
							WatchConnectivityService.shared.send(.startDiscovery(projectID: UUID()))
						}
//					}
				}
				.listStyle(.carousel)
				.navigationTitle("Companion") // TODO: Title?
			} else {
				BlockerView()
			}
		}
		.animation(.default, value: WatchConnectivityService.shared.phoneState?.isForeground)
    }
}

struct NavListItemView: View {
	let title: String
	let systemImage: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: systemImage)
				.font(.title)
				.foregroundStyle(.accent)
			
			Text(title)
				.bold()
		}
		.frame(height: 100)
	}
}

#Preview {
	ContentView()
}
