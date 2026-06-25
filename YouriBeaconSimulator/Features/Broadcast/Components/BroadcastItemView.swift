//
//  BroadcastItemView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct BroadcastItemView: View {
	// TODO: Broadcast item model and onlcick stuff
	let isBroadcasting: Bool
	let shouldDisableBroadcast: Bool
	
	let onBroadcastClick: () -> Void
	let onDeleteClick: () -> Void
	let onEditCLick: () -> Void
	let onShareClick: () -> Void
	let onMeasuredTxPowerChange: (Int) -> Void
	
	var body: some View {
		VStack {
			HStack {
				if isBroadcasting {
					Image(systemName: "dot.radiowaves.left.and.right")
						.symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.periodic(delay: 0.3)))
				}
				
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
				.foregroundStyle(shouldDisableBroadcast ? .gray : .primary)
				
				Spacer()
				
				Button {
					withAnimation() {
						onBroadcastClick()
					}
				} label: {
					Label("Broadcast", systemImage: isBroadcasting ? "square.fill" : "play.fill")
						.contentTransition(.symbolEffect(.replace))
						.foregroundStyle(isBroadcasting ? .red : .primary)
						// Larger hitbox
						.padding(10)
						.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
				.labelStyle(.iconOnly)
				.disabled(shouldDisableBroadcast)
			}
			
			if isBroadcasting {
				MeasuredTXPowerView(initialValue: -59) { power in
					onMeasuredTxPowerChange(power)
				}
			}
		}
		.listRowBackground(shouldDisableBroadcast ? Color.gray.opacity(0.2) : nil)
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			if !isBroadcasting {
				Button {
					onDeleteClick()
				} label: {
					Label("Delete", systemImage: "trash")
				}
				.tint(.red)
				
				Button {
					onEditCLick()
				} label: {
					Label("Edit", systemImage: "square.and.pencil")
				}
				.tint(.orange)
				
				Button {
					onShareClick()
				} label: {
					Label("Share", systemImage: "square.and.arrow.up")
				}
				.tint(.blue)
			}
		}
		.contextMenu {
			if !isBroadcasting {
				Button {
					onShareClick()
				} label: {
					Label("Share", systemImage: "square.and.arrow.up")
				}
				.tint(.blue)
				
				Button {
					onEditCLick()
				} label: {
					Label("Edit", systemImage: "square.and.pencil")
				}
				.tint(.orange)
				
				Button() {
					onDeleteClick()
				} label: {
					Label("Delete", systemImage: "trash")
				}
				.tint(.red)
			}
		}
	}
}

#Preview {
	@Previewable @State var isBroadcasting: Bool = true
	
	List {
		// Simulate other beacon while one is broadcasting
		BroadcastItemView(
			isBroadcasting: false,
			shouldDisableBroadcast: isBroadcasting,
			onBroadcastClick: {},
			onDeleteClick: {},
			onEditCLick: {},
			onShareClick: {},
			onMeasuredTxPowerChange: { _ in }
		)
		
		BroadcastItemView(
			isBroadcasting: isBroadcasting,
			shouldDisableBroadcast: false,
			onBroadcastClick: { isBroadcasting.toggle() },
			onDeleteClick: {},
			onEditCLick: {},
			onShareClick: {},
			onMeasuredTxPowerChange: { _ in }
		)
		
		// Simulate other beacon while one is broadcasting
		BroadcastItemView(
			isBroadcasting: false,
			shouldDisableBroadcast: isBroadcasting,
			onBroadcastClick: {},
			onDeleteClick: {},
			onEditCLick: {},
			onShareClick: {},
			onMeasuredTxPowerChange: { _ in }
		)
	}
}
