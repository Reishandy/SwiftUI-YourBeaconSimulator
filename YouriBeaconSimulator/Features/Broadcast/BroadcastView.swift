//
//  BroadcastView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 24/06/26.
//

import SwiftUI

struct BroadcastView: View {
	// TODO: Add a default on the measured tx power slider that sets to -59 on form
	
	// TODO: Animation
	var body: some View {
		NavigationStack {
			// TODO: Group by uuid sort by major asc
			// TODO: Delete confirmation sheet
			// TODO: Empty and permission state
			List {
				ForEach(1...5, id: \.self) { sec in
					Section {
						ForEach(1...3, id: \.self) { num in
							BroadcastItemView(
								broadcastBeacon: BroadcastBeacon(
									projectName: "Project \(sec)", beaconUUID: UUID().uuidString, beaconName: "Beacon \(num)", majorID: sec, minorID: Int.random(in: 100...999)
								),
								isBroadcasting: false,
								shouldDisableBroadcast: false,
								onBroadcastClick: {},
								onDeleteClick: {},
								onEditCLick: {
									// TODO: Share Name, UUID, Major, Minor
								},
								onShareClick: {},
								onMeasuredTxPowerChange: { _ in }
							)
						}
					} header: {
						BroadcastSectionHeaderView(title: "Project \(sec)", uuid: UUID().uuidString)
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
