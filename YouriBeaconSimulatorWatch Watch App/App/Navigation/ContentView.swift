//
//  ContentView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

struct ContentView: View {
	@Environment(WatchConnectivityService.self) private var connectivity
	
	var body: some View {
		NavigationStack {
			// TODO: Error toeast
			if connectivity.showFailureToast {
				Label("Command failed", systemImage: "exclamationmark.triangle")
					.font(.caption2)
					.padding(6)
					.background(.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
			}
			
			if connectivity.phoneState?.isForeground == true {
				// TODO: Nav
				List {
					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Broadcast",
							systemImage: "sensor.radiowaves.left.and.right.fill"
						)
						.onTapGesture {
							connectivity.send(.startBroadcast(beaconID: UUID()))
						}
					}
					
					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Discover",
							systemImage: "dot.radiowaves.up.forward"
						)
						.onTapGesture {
							connectivity.send(.startDiscovery(projectID: UUID()))
						}
					}
				}
				.listStyle(.carousel)
				.navigationTitle("Companion") // TODO: Title?
			} else {
				BlockerView()
			}
		}
		.animation(.default, value: connectivity.phoneState?.isForeground)
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

#Preview("Idle (Foreground)") {
	ContentView()
		.environment(WatchConnectivityService.previewMock(
			state: WatchPreviewData.idleForegroundState
		))
}

#Preview("Discovering Beacons") {
	ContentView()
		.environment(WatchConnectivityService.previewMock(
			state: WatchPreviewData.discoveringState
		))
}

#Preview("App in Background (Blocked)") {
	ContentView()
		.environment(WatchConnectivityService.previewMock(
			state: WatchPreviewData.backgroundState
		))
}
#Preview("Error Toast") {
	ContentView()
		.environment(WatchConnectivityService.previewMock(
			state: WatchPreviewData.idleForegroundState,
			showFailureToast: true
		))
}
