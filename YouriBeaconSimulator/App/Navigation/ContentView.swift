//
//  ContentView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		TabView {
			BroadcastView()
				.tabItem {
					Label("Broadcast", systemImage: "antenna.radiowaves.left.and.right")
				}
			
			DiscoverView()
				.tabItem {
					Label("Discover", systemImage: "wifi") // TODO: Better Icon
				}
		}
    }
}

#Preview {
    ContentView()
}
