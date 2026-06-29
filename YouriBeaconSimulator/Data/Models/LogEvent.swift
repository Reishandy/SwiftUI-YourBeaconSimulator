//
//  LogEvent.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData

@Model
final class LogEvent: Identifiable {
	var id: UUID = UUID()
	var timestamp: Date = Date.now
	var message: String = ""
	var categoryRawValue: String = LogCategory.system.rawValue
	
	var session: LogSession?
	
	var category: LogCategory {
		get { LogCategory(rawValue: categoryRawValue) ?? .system }
		set { categoryRawValue = newValue.rawValue }
	}
	
	init(message: String, category: LogCategory) {
		self.id = UUID()
		self.timestamp = .now
		self.message = message
		self.categoryRawValue = category.rawValue
	}
}
