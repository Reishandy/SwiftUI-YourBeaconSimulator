//
//  DiscoverView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        Text("Discover")
			.navigationTitle("Discover")
			.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	NavigationStack {
		DiscoverView()
	}
}
