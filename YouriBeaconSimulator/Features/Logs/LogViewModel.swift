//
//  LogViewModel.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
class LogViewModel {
	private var modelContext: ModelContext
	
	private(set) var sessions: [LogSession] = []
	
	var showClearConfirmation = false
	
	var selectedEvent: LogEvent?
	var selectedSession: LogSession?
	var isDeleteEventConfirmationPresented = false
	var isDeleteSessionConfirmationPresented = false
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		self.fetchData()
	}
	
	func fetchData() {
		do {
			let descriptor = FetchDescriptor<LogSession>(
				sortBy: [SortDescriptor(\.startTime, order: .reverse)]
			)
			self.sessions = try modelContext.fetch(descriptor)
		} catch {
			print("ERROR > Failed populating LogViewModel: \(error)")
		}
	}
	
	func clearAllLogs() {
		do {
			try modelContext.delete(model: LogSession.self)
			try modelContext.save()
			fetchData()
		} catch {
			print("ERROR > Failed to clear logs: \(error)")
		}
	}
	
	func deleteSession() {
		guard let sessionToDelete = selectedSession else { return }
		
		modelContext.delete(sessionToDelete)
		do {
			try modelContext.save()
			fetchData()
			selectedSession = nil
		} catch {
			print("ERROR > Failed to delete session: \(error)")
		}
	}
	
	func deleteEvent() {
		guard let eventToDelete = selectedEvent else { return }
		
		let parentSession = eventToDelete.session
		modelContext.delete(eventToDelete)
		
		do {
			try modelContext.save()
			
			if let session = parentSession, (session.events?.isEmpty ?? true) {
				modelContext.delete(session)
				try modelContext.save()
			}
			
			fetchData()
			selectedEvent = nil
		} catch {
			print("ERROR > Failed to delete event: \(error)")
		}
	}
}
