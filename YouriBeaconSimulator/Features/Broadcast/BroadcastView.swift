//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct BroadcastView: View {
	// TODO: Broadcast View
	
    var body: some View {
		NavigationStack {
			List {
				ForEach(1...99, id: \.self) { num in
					Text("Item \(num)")
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("Add", systemImage: "plus") {
						
					}
				}
			}
		}
    }
}

#Preview {
    BroadcastView()
}
