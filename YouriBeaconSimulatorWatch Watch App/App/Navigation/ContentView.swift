//
//  ContentView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

struct ContentView: View {
	@Environment(WatchConnectivityService.self) private var connectivity
	
	private var isShowingOverlay: Bool {
		(connectivity.phoneState?.discoveringProjectUUID != nil) ||
		(connectivity.phoneState?.broadcastingBeaconID != nil) ||
		connectivity.showError ||
		(connectivity.phoneState?.isForeground == false)
	}
	
	private var projects: [BroadcastProjectSummary] {
		connectivity.phoneState?.broadcastableProjects ?? []
	}
	
	var body: some View {
		ZStack {
			NavigationStack {
				List {
					NavigationLink(destination: BroadcastView(
						isShowingOverlay: isShowingOverlay,
						projects: projects,
						onClick: { beaconID in
							connectivity.send(.startBroadcast(beaconID: beaconID))
						}
					)) {
						NavListItemView(
							title: "Broadcast",
							systemImage: "sensor.radiowaves.left.and.right.fill"
						)
					}
					
					NavigationLink(destination: DiscoverView(
						isShowingOverlay: isShowingOverlay,
						projects: projects,
						onClick: { projectID in
							connectivity.send(.startDiscovery(projectID: projectID))
						}
					)) {
						NavListItemView(
							title: "Discover",
							systemImage: "dot.radiowaves.up.forward"
						)
					}
				}
				.listStyle(.carousel)
				.scrollIndicators(isShowingOverlay ? .hidden : .automatic)
				.scrollDisabled(isShowingOverlay)
				.navigationTitle("Companion")
			}
			
			if let state = connectivity.phoneState,
			   let discoveringProjectUUID = state.discoveringProjectUUID,
			   let project = state.broadcastableProjects.first(where: { $0.proximityUUID == discoveringProjectUUID }) {
				ActiveDiscoverView(
					projectName: project.name,
					discoveredBeacons: connectivity.phoneState?.discoveredBeacons ?? [],
					onStop: {
						connectivity.send(.stopDiscovery)
					}
				)
			}
			
			if let state = connectivity.phoneState,
			   let beaconID = state.broadcastingBeaconID,
			   let project = state.broadcastableProjects.first(where: { $0.beacons.contains(where: { $0.id == beaconID }) }),
			   let beacon = project.beacons.first(where: { $0.id == beaconID }) {
				
				ActiveBroadcastView(
					beacon: beacon,
					projectName: project.name,
					onStop: {
						connectivity.send(.stopBroadcast)
					}
				)
			}
			
			if connectivity.showError {
				ErrorView()
			}
			
			if connectivity.phoneState?.isForeground == false {
				BlockerView()
			}
		}
		.animation(.default, value: connectivity.phoneState?.isForeground)
		.animation(.default, value: connectivity.phoneState?.discoveringProjectUUID)
		.animation(.default, value: connectivity.phoneState?.broadcastingBeaconID)
		.animation(.easeInOut, value: connectivity.showError)
		.sensoryFeedback(.impact(weight: .heavy), trigger: connectivity.phoneState?.isForeground)
		.sensoryFeedback(.impact(weight: .heavy), trigger: connectivity.phoneState?.discoveringProjectUUID)
		.sensoryFeedback(.impact(weight: .heavy), trigger: connectivity.phoneState?.broadcastingBeaconID)
		.sensoryFeedback(.impact(weight: .heavy), trigger: connectivity.showError)
	}
}

struct NavListItemView: View {
	let title: String
	let systemImage: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: systemImage)
				.font(.title2)
				.foregroundStyle(.accent)
			
			Text(title)
				.bold()
		}
		.padding()
		.padding(.vertical)
	}
}

#Preview {
	ContentView()
		.environment(WatchConnectivityService.previewMock(
			state: WatchPreviewData.idleForegroundState
		))
}
