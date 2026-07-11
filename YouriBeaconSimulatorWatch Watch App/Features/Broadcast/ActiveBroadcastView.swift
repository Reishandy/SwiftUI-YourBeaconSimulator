//
//  ActiveBroadcastView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct ActiveBroadcastView: View {
	let beacon: BroadcastBeaconSummary
	let projectName: String
	let onStop: () -> Void
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 8) {
				Spacer()
				
				Image(systemName: "dot.radiowaves.left.and.right")
					.font(.largeTitle)
					.symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.periodic(delay: 0.3)))
				
				VStack {
					Text("Major: \(String(beacon.majorID))")
					
					Text("Minor: \(String(beacon.minorID))")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				
				Spacer()
				
				Text(projectName)
					.font(.caption2)
					.foregroundStyle(.secondary)
			}
			.padding()
			.navigationTitle("Broadcasting")
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
	}
}

#Preview {
	ActiveBroadcastView(
		beacon: BroadcastBeaconSummary(
			id: UUID(),
			beaconName: "Name",
			majorID: 12,
			minorID: 65535
		),
		projectName: "Front Lobby Long Name I guess",
		onStop: {}
	)
}
