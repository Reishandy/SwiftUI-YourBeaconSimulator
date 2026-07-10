//
//  PhoneConnectivityService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

#if os(iOS)
import WatchConnectivity
import Observation

@Observable
final class PhoneConnectivityService: NSObject, WCSessionDelegate {
	static let shared = PhoneConnectivityService()
	
	private(set) var isWatchReachable: Bool = false
	
	var onCommand: ((WatchCommand) -> Void)?
	
	private var session: WCSession { WCSession.default }
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	private override init() {
		super.init()
		guard WCSession.isSupported() else { return }
		session.delegate = self
		session.activate()
	}
	
	func pushState(_ state: PhoneState) {
		guard WCSession.isSupported(), session.activationState == .activated else { return }
		guard let data = try? encoder.encode(state) else { return }
		try? session.updateApplicationContext([ConnectivityKey.payload: data])
	}
	
	func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
		guard
			let data = message[ConnectivityKey.payload] as? Data,
			let command = try? decoder.decode(WatchCommand.self, from: data)
		else { return }
		
		Task { @MainActor in self.onCommand?(command) }
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		Task { @MainActor in self.isWatchReachable = session.isReachable }
	}
	
	func sessionReachabilityDidChange(_ session: WCSession) {
		Task { @MainActor in self.isWatchReachable = session.isReachable }
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) { }
	
	func sessionDidDeactivate(_ session: WCSession) {
		session.activate()
	}
}
#endif
