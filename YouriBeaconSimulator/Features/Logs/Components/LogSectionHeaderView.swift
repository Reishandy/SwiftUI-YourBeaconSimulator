//
//  LogSectionHeaderView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 29/06/26.
//

import SwiftUI

struct LogSectionHeaderView: View {
	let session: LogSession
	
	var body: some View {
		HStack {
			Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
				.font(.subheadline)
				.textCase(nil)
			
			Spacer()
			
			HStack(spacing: 4) {
				Image(systemName: "tag.fill")
				Text(session.id.uuidString.prefix(8))
			}
			.font(.caption2)
			.foregroundStyle(.secondary)
			.textCase(nil)
		}
	}
}

#Preview {
	List {
		Section {
			LogItemView(event: LogEvent(message: "Test", category: .discovery), onEventDeleteClick: {}, onSessionDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .broadcast), onEventDeleteClick: {}, onSessionDeleteClick: {})
			LogItemView(event: LogEvent(message: "Test", category: .background), onEventDeleteClick: {}, onSessionDeleteClick: {})
			LogItemView(event: LogEvent(message: "This is a long as message that sometimes happens because it is logging you know? I don't even know what I am doing", category: .system), onEventDeleteClick: {}, onSessionDeleteClick: {})
		} header: {
			LogSectionHeaderView(session: LogSession())
		}
	}
	
}
