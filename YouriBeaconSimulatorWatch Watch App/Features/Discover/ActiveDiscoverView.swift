//
//  ActiveDiscoverView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct ActiveDiscoverView: View {
	var body: some View {
		NavigationStack {
			Text("Active Discovery")
				.navigationTitle("Discovering")
				.navigationBarTitleDisplayMode(.inline)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.black)
	}
}

#Preview {
	ActiveDiscoverView()
}
