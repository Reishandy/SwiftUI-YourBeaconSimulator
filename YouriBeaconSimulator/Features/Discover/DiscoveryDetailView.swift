//
//  DiscoveryDetailView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 27/06/26.
//

import SwiftUI

struct DiscoveryDetailView: View {
	let discoveredBeacon: DiscoveredBeacon
	
    var body: some View {
		Text("Selected: \(discoveredBeacon.id)")
    }
}

#Preview {
    DiscoveryDetailView(
		discoveredBeacon: DiscoveredBeacon(
			uuid: UUID(),
			major: 1,
			minor: 100,
			rssi: -35,
			accuracy: 0.2,
			proximity: .immediate,
			lastSeen: .now
		)
	)
}
