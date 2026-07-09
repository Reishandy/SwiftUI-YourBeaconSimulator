//
//  WatchConnectivityService.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 09/07/26.
//

import WatchConnectivity
import Observation

@Observable
final class WatchConnectivityService: NSObject, WCSessionDelegate {
	private(set) var isPhoneForeground: Bool = false
	private(set) var isReachable: Bool = false
	
	private var session: WCSession { WCSession.default }
	
	override init() {
		super.init()
		guard WCSession.isSupported() else { return }
		session.delegate = self
		session.activate()
	}
	
	func send(_ command: WatchCommand, completion: @escaping (WatchCommandResult) -> Void) {
		guard session.isReachable, let data = try? JSONEncoder().encode(command) else {
			completion(WatchCommandResult(success: false, message: "Phone not reachable"))
			return
		}
		
		session.sendMessage([ConnectivityKey.payload: data], replyHandler: { reply in
			if let resultData = reply[ConnectivityKey.payload] as? Data,
			   let result = try? JSONDecoder().decode(WatchCommandResult.self, from: resultData) {
				Task { @MainActor in completion(result) }
			} else {
				Task { @MainActor in completion(WatchCommandResult(success: false, message: "Malformed reply")) }
			}
		}, errorHandler: { error in
			Task { @MainActor in completion(WatchCommandResult(success: false, message: error.localizedDescription)) }
		})
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		applyContext(session.receivedApplicationContext)
		Task { @MainActor in self.isReachable = session.isReachable }
	}
	
	func sessionReachabilityDidChange(_ session: WCSession) {
		Task { @MainActor in self.isReachable = session.isReachable }
	}
	
	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
		applyContext(applicationContext)
	}
	
	private func applyContext(_ context: [String: Any]) {
		let foreground = context[PhoneToWatchContextKey.isForeground] as? Bool ?? false
		Task { @MainActor in self.isPhoneForeground = foreground }
	}
}

#if DEBUG
extension WatchConnectivityService {
	static func preview(isPhoneForeground: Bool) -> WatchConnectivityService {
		let service = WatchConnectivityService()
		service.isPhoneForeground = isPhoneForeground
		return service
	}
}
#endif
