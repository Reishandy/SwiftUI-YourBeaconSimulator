//
//  BeaconProximity.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 26/06/26.
//

import SwiftUI

enum BeaconProximity: String, CaseIterable, Sendable {
	case immediate = "Immediate"
	case near = "Near"
	case far = "Far"
	case unknown = "Unknown"
	
	var iconColor: Color {
		switch self {
		case .immediate:
			return .green
		case .near:
			return .yellow
		case .far:
			return .red
		case .unknown:
			return .gray
		}
	}
	
	var iconVariableValue: Double {
		switch self {
		case .immediate:
			return 1.0
		case .near:
			return 0.5
		case .far:
			return 0.1
		case .unknown:
			return 0.0
		}
	}
}
