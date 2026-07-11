//
//  BroadcastView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct BroadcastView: View {
	let isShowingOverlay: Bool
	let projects: [BroadcastProjectSummary]
	let onClick: (UUID) -> Void
	
	var body: some View {
		List {
			ForEach(projects) { project in
				Section(project.name) {
					ForEach(project.beacons) { beacon in
						Button {
							onClick(beacon.id)
						} label: {
							HStack {
								VStack(alignment: .leading) {
									Text(beacon.beaconName)
										.font(.caption)
									
									Text("Major: \(String(beacon.majorID))")
										.font(.caption2)
										.foregroundColor(.secondary)
									
									Text("Minor: \(String(beacon.minorID))")
										.font(.caption2)
										.foregroundColor(.secondary)
								}
								
								Spacer(minLength: 12)
								
								Image(systemName: "play.fill")
							}
							.padding()
						}
					}
				}
			}
		}
		.listStyle(.carousel)
		.scrollIndicators(isShowingOverlay ? .hidden : .automatic)
		.scrollDisabled(isShowingOverlay)
		.navigationTitle("Broadcast")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationStack {
		BroadcastView(
			isShowingOverlay: false,
			projects: WatchPreviewData.projects,
			onClick: { _ in }
		)
	}
}
