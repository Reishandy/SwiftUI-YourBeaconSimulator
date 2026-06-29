//
//  LogSession.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData

@Model
final class LogSession: Identifiable {
	var id: UUID = UUID()
	var startTime: Date = Date.now
	
	@Relationship(deleteRule: .cascade, inverse: \LogEvent.session)
	var events: [LogEvent]? = []
	
	init(id: UUID = UUID(), startTime: Date = Date.now) {
		self.id = id
		self.startTime = startTime
	}
}
