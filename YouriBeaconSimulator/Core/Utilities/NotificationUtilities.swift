//
//  NotificationUtilities.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 27/06/26.
//

import UserNotifications

struct NotificationUtilities {
	static func send(title: String, body: String) {
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = body
		content.sound = .default
		
		// A nil trigger fires the notification instantly,
		// which is required for immediate background feedback.
		let request = UNNotificationRequest(
			identifier: UUID().uuidString,
			content: content,
			trigger: nil
		)
		
		UNUserNotificationCenter.current().add(request)
	}
}
