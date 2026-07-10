//
//  ActiveBroadcastView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct ActiveBroadcastView: View {
	var body: some View {
		NavigationStack {
			Text("Active Broadcast")
				.navigationTitle("Broadcasting")
				.navigationBarTitleDisplayMode(.inline)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.black)
	}
}

#Preview {
	ActiveBroadcastView()
}
