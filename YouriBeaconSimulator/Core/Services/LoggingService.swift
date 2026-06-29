//
//  LoggingService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData

@ModelActor
public actor LoggingService {
	private var currentSessionID: PersistentIdentifier?
	
	func startNewSession() {
		let session = LogSession()
		modelContext.insert(session)
		
		do {
			try modelContext.save()
			currentSessionID = session.persistentModelID
			print("Started new logging session: \(session.id)")
		} catch {
			print("Failed to start logging session: \(error)")
		}
	}
	
	func log(message: String, category: LogCategory) {
		guard let sessionID = currentSessionID,
			  let session = modelContext.model(for: sessionID) as? LogSession else {
			return
		}
		
		let event = LogEvent(message: message, category: category)
		modelContext.insert(event)
		event.session = session
		
		do {
			try modelContext.save()
		} catch {
			print("Failed to save log event: \(error)")
		}
	}
}
