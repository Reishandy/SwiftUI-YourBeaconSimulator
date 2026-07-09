//
//  SharedConnectivityProtocol.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import Foundation

enum ConnectivityKey {
	static let payload = "payload"
}

enum PhoneToWatchContextKey {
	static let isForeground = "isForeground"
}

// TODO: ADD COMMANDS HERE (SYNC BOTH TARGET)
enum WatchCommand: Codable {
	case ping
}

struct WatchCommandResult: Codable {
	let success: Bool
	let message: String?
}
