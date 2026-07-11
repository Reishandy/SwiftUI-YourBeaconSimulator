//
//  ActiveDiscoverView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct ActiveDiscoverView: View {
	let discoveredBeacons: [DiscoveredBeaconSummary]
	let onStop: () -> Void
	
	var body: some View {
		NavigationStack {
			Group {
				if discoveredBeacons.isEmpty {
					VStack(spacing: 4) {
						Image(systemName: "dot.radiowaves.up.forward")
							.font(.largeTitle)
							.symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.periodic(delay: 0.3)))
						
						Text("Discovering")
							.font(.headline)
							.multilineTextAlignment(.center)
					}
					.padding()
				} else {
					List {
						ForEach(discoveredBeacons) { beacon in
							HStack(spacing: 10) {
								if beacon.isCurrentlyActive {
									Image(systemName: "wifi", variableValue: beacon.proximity.iconVariableValue)
										.foregroundStyle(beacon.proximity.iconColor)
										.font(.title2)
								} else {
									Image(systemName: "wifi.slash")
										.foregroundStyle(.gray)
										.font(.title2)
								}
								
								VStack(alignment: .leading) {
									Text("Major: \(String(beacon.major))")
									
									Text("Minor: \(String(beacon.minor))")
										.font(.caption)
										.foregroundStyle(.secondary)
								}
							}
						}
						
						HStack(spacing: 12) {
							Text("Discovering")
								.font(.headline)
								.foregroundStyle(.secondary)
							
							Image(systemName: "dot.radiowaves.up.forward")
								.font(.title2)
								.symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.periodic(delay: 0.3)))
						}
						.frame(maxWidth: .infinity)
					}
					.listStyle(.carousel)
				}
			}
			.navigationTitle("Discovering")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Stop", systemImage: "stop.fill") {
						onStop()
					}
					.labelStyle(.iconOnly)
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.black)
		.animation(.default, value: discoveredBeacons)
	}
}

#Preview("Active") {
	ActiveDiscoverView(
		discoveredBeacons: WatchPreviewData.discoveredBeacons,
		onStop: {}
	)
}

#Preview("Empty") {
	ActiveDiscoverView(
		discoveredBeacons: [],
		onStop: {}
	)
}
