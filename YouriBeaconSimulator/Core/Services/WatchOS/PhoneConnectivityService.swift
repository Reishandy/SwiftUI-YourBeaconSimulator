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
	private(set) var isWatchReachable: Bool = false
	
	var commandHandler: ((WatchCommand) -> WatchCommandResult)?
	
	private var session: WCSession { WCSession.default }
	
	override init() {
		super.init()
		guard WCSession.isSupported() else { return }
		session.delegate = self
		session.activate()
	}
	
	func updateForegroundState(isForeground: Bool) {
		guard WCSession.isSupported(), session.activationState == .activated else { return }
		do {
			try session.updateApplicationContext([
				PhoneToWatchContextKey.isForeground: isForeground
			])
		} catch {
			print("Failed to push foreground state to watch: \(error)")
		}
	}
	
	func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		guard
			let data = message[ConnectivityKey.payload] as? Data,
			let command = try? JSONDecoder().decode(WatchCommand.self, from: data)
		else {
			replyHandler([ConnectivityKey.payload: (try? JSONEncoder().encode(
				WatchCommandResult(success: false, message: "Malformed command")
			)) ?? Data()])
			return
		}
		
		let result = commandHandler?(command)
		?? WatchCommandResult(success: false, message: "No handler registered")
		
		let resultData = (try? JSONEncoder().encode(result)) ?? Data()
		replyHandler([ConnectivityKey.payload: resultData])
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		Task { @MainActor in
			self.isWatchReachable = session.isReachable
		}
	}
	
	func sessionReachabilityDidChange(_ session: WCSession) {
		Task { @MainActor in
			self.isWatchReachable = session.isReachable
		}
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) { }
	
	func sessionDidDeactivate(_ session: WCSession) {
		session.activate()
	}
}
#endif
