//
//  DiscoverItemView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import SwiftUI

struct DiscoverItemView: View {
	let discoveredBeacon: DiscoveredBeacon
	
    var body: some View {
		HStack(spacing: 10) {
			if discoveredBeacon.isCurrentlyActive {
				Image(systemName: "wifi", variableValue: discoveredBeacon.proximity.iconVariableValue)
					.foregroundStyle(discoveredBeacon.proximity.iconColor)
					.font(.title2)
			} else {
				Image(systemName: "wifi.slash")
					.foregroundStyle(.gray)
					.font(.title2)
			}
			
			VStack(alignment: .leading) {
				HStack {
					Text("Major: \(String(discoveredBeacon.major))")
						.font(.headline)
						
					Text("Minor: \(String(discoveredBeacon.minor))")
						.font(.headline)
				}
				
				Text(discoveredBeacon.uuid.uuidString)
					.font(.callout.monospaced())
					.opacity(0.8)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
		}
    }
}

#Preview {
	List {
		ForEach(PreviewContainer.discoveredBeaconPreviews) { beacon in
			NavigationLink(value: beacon) {
				DiscoverItemView(discoveredBeacon: beacon)
			}
		}
	}
}
