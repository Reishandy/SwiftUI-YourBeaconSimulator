//
//  DiscoverView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct DiscoverView: View {
	// TODO: Discover View
	let items = (1...99).map { "Item \($0)" }
	
	@State private var selectedItem: String?
	
	var body: some View {
		NavigationSplitView {
			List(items, id: \.self, selection: $selectedItem) { item in
				NavigationLink(item, value: item)
			}
			.navigationTitle("Discover")
			.navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 400)
			
		} detail: {
			if let selectedItem {
				Text("Selected: \(selectedItem)")
					.navigationTitle(selectedItem)
			} else {
				Text("Select an item from the sidebar")
					.foregroundColor(.secondary)
			}
		}
	}
}

#Preview {
	DiscoverView()
}
