//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct BroadcastView: View {
	// TODO: Broadcast View
	// TODO: Group by uuid sort by major asc
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(1...5, id: \.self) { sec in
					Section {
						ForEach(1...3, id: \.self) { num in
							BroadcastItemView()
						}
					} header: {
						BroadcastSectionHeaderView()
							.padding(.leading, -10)
					}
					.headerProminence(.increased)
				}
			}
			.navigationTitle("Broadcast")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
			}
		}
	}
}

#Preview {
	BroadcastView()
}
