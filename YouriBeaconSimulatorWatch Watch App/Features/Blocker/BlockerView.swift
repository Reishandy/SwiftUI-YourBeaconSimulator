//
//  BlockerView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

struct BlockerView: View {
    var body: some View {
		VStack(spacing: 4) {
			Image(systemName: "exclamationmark.triangle")
				.font(.title)
				.foregroundStyle(.red)
			
			Text("App Not in Foreground")
				.font(.headline)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
			
			Text("Please open Your Beacon Simulator on your paired iPhone to continue.")
				.font(.caption2)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding()
    }
}

#Preview {
    BlockerView()
}
