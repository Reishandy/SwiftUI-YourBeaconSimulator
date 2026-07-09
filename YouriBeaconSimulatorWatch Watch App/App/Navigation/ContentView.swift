//
//  ContentView.swift
//  YouriBeaconSimulatorWatch Watch App
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import SwiftUI

struct ContentView: View {
	@Environment(WatchConnectivityService.self) private var watchConnectivityService
	
    var body: some View {
		NavigationStack {
			if watchConnectivityService.isPhoneForeground {
				// TODO: Nav
				List {
					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Broadcast",
							systemImage: "sensor.radiowaves.left.and.right.fill"
						)
					}
					
					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Discover",
							systemImage: "dot.radiowaves.up.forward"
						)
					}
					
					NavigationLink(destination: EmptyView()) {
						NavListItemView(
							title: "Logs",
							systemImage: "text.document.fill"
						)
					}
				}
				.listStyle(.carousel)
				.navigationTitle("Companion") // TODO: Title?
			} else {
				BlockerView()
			}
		}
		.animation(.default, value: watchConnectivityService.isPhoneForeground)
    }
}

struct NavListItemView: View {
	let title: String
	let systemImage: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: systemImage)
				.font(.title)
				.foregroundStyle(.accent)
			
			Text(title)
				.bold()
		}
		.frame(height: 100)
	}
}

#Preview {
	ContentView()
		.environment(WatchConnectivityService.preview(isPhoneForeground: true))
}
