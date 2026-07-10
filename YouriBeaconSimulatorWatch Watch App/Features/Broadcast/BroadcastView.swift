//
//  BroadcastView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct BroadcastView: View {
    var body: some View {
        Text("Broadcast")
			.navigationTitle("Broadcast")
			.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	NavigationStack {
		BroadcastView()
	}
}
