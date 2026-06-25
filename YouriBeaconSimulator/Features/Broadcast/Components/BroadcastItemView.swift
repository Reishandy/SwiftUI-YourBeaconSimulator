//
//  BroadcastItemView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct BroadcastItemView: View {
	// TODO: Broadcast item model and onlcick stuff
	
	@State private var isPlay: Bool = false // TODO: Remove debug
	
    var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Beacon name")
					.font(.headline)
				
				HStack {
					Text("Major: 1")
						.font(.subheadline)
						.opacity(0.8)
					
					Text("Minor: 2")
						.font(.subheadline)
						.opacity(0.8)
				}
			}
			
			Spacer()
			
			Button {
				// TODO: onBroadcastClick
				isPlay.toggle()
			} label: {
				Label("Broadcast", systemImage: isPlay ? "square.fill" : "play.fill")
					.contentTransition(.symbolEffect(.replace))
					// Larger hitbox
					.padding(10)
					.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.labelStyle(.iconOnly)
			// TODO: Disable if at leat one is playing
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button {
				// TODO: Delete
			} label: {
				Label("Delete", systemImage: "trash")
			}
			.tint(.red)
			
			Button {
				// TODO: Edit
			} label: {
				Label("Edit", systemImage: "square.and.pencil")
			}
			.tint(.orange)
			
			Button {
				// TODO: Share Name, UUID, Major, Minor
			} label: {
				Label("Share", systemImage: "square.and.arrow.up")
			}
			.tint(.blue)
		}
		.contextMenu {
			Button {
				// TODO: Share Name, UUID, Major, Minor
			} label: {
				Label("Share", systemImage: "square.and.arrow.up")
			}
			.tint(.blue)
			
			Button {
				// TODO: Edit
			} label: {
				Label("Edit", systemImage: "square.and.pencil")
			}
			.tint(.orange)
			
			Button() {
				// TODO: Delete
			} label: {
				Label("Delete", systemImage: "trash")
			}
			.tint(.red)
		}
    }
}

#Preview {
	List {
		BroadcastItemView()
	}
}
