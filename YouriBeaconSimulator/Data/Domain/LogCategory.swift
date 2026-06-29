//
//  LogCategory.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import SwiftUI

enum LogCategory: String, Codable, Sendable {
	case broadcast = "Broadcast"
	case discovery = "Discovery"
	case background = "Background"
	case system = "System"
	
	var iconName: String {
		switch self {
		case .broadcast: return "antenna.radiowaves.left.and.right"
		case .discovery: return "magnifyingglass"
		case .background: return "moon.fill"
		case .system: return "gearshape.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .broadcast: return .blue
		case .discovery: return .green
		case .background: return .indigo
		case .system: return .gray
		}
	}
}
