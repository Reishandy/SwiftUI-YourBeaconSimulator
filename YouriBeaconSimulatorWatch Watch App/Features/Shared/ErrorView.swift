//
//  ErrorView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 10/07/26.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
		VStack(spacing: 4) {
			Image(systemName: "exclamationmark.triangle")
				.font(.title)
			
			Text("Command Failed")
				.font(.headline)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.foregroundStyle(.white)
		.background(.red)
    }
}

#Preview {
    ErrorView()
}
