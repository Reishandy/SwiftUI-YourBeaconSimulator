//
//  NotificationPermissionManager.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

import UserNotifications
import Observation

@Observable
@MainActor
public final class NotificationPermissionManager {
	public private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
	
	public init() {
		Task { await checkStatus() }
	}
	
	public func checkStatus() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		self.authorizationStatus = settings.authorizationStatus
	}
	
	public func requestPermission() async -> UNAuthorizationStatus {
		do {
			try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
		} catch {
			print("Failed to request notification permission: \(error)")
		}
		
		await checkStatus()
		return self.authorizationStatus
	}
}
