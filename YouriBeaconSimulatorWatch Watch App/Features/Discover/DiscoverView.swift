//
//  DiscoverView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct DiscoverView: View {
	let projects: [BroadcastProjectSummary]
	let onClick: (UUID) -> Void
	
    var body: some View {
		List {
			ForEach(projects) { project in
				Button {
					onClick(project.id)
				} label: {
					VStack(alignment: .leading) {
						Text(project.name)
							.font(.caption)
						
						Text("\(project.beacons.count) beacons")
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.padding()
				}
			}
		}
		.listStyle(.carousel)
		.navigationTitle("Discover")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	NavigationStack {
		DiscoverView(
			projects: WatchPreviewData.projects,
			onClick: { _ in }
		)
	}
}
