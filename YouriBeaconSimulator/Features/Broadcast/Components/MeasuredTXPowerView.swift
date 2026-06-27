//
//  MeasuredTXPowerView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct MeasuredTXPowerView: View {
	let onMeasuredTxPowerChange: (Int) -> Void
	
	@State private var measuredTxPower: Double
	
	init(
		initialValue: Int,
		onMeasuredTxPowerChange: @escaping (Int) -> Void
	) {
		self.onMeasuredTxPowerChange = onMeasuredTxPowerChange
		
		self._measuredTxPower = State(initialValue: Double(initialValue))
	}
	
	var body: some View {
		VStack {
			Slider(value: $measuredTxPower, in: (-70)...(0)) {
#if os(iOS)
				Text("Measured TX Power")
#endif
			} minimumValueLabel: {
				Text("-70 dBm")
					.font(.caption)
			} maximumValueLabel: {
				Text("0 dBm")
					.font(.caption)
			} onEditingChanged: { _ in
				onMeasuredTxPowerChange(Int(measuredTxPower.rounded()))
			}
			
			HStack {
				Text("Closer")
					.font(.caption)
					.foregroundColor(.secondary)
				
				Spacer()
				
				Text("Current measured TX power: \(String(measuredTxPower.rounded())) dBm")
					.font(.caption2)
					.foregroundColor(.secondary)
				
				Spacer()
				
				Text("Further")
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
	}
}

#Preview {
	MeasuredTXPowerView(initialValue: -59) { _ in }
}
