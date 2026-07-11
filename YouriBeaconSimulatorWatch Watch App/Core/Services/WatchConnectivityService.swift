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
	static let shared = WatchConnectivityService()
	
	private(set) var phoneState: PhoneState?
	private(set) var isReachable: Bool = false
	private(set) var showError: Bool = false
	
	private var errorClearTask: Task<Void, Never>?
	private var session: WCSession { WCSession.default }
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	private override init() {
		super.init()
		guard WCSession.isSupported() else { return }
		session.delegate = self
		session.activate()
	}
	
	private init(isMock: Bool) {
		super.init()
	}
	
	static func previewMock(state: PhoneState? = nil, showFailureToast: Bool = false) -> WatchConnectivityService {
		let service = WatchConnectivityService(isMock: true)
		service.phoneState = state
		service.showError = showFailureToast
		return service
	}
	
	func send(_ command: WatchCommand) {
		guard session.isReachable, let data = try? encoder.encode(command) else { return }
		session.sendMessage([ConnectivityKey.payload: data], replyHandler: nil) { error in
			// TODO: Display error on state?
			print("WatchConnectivityService: send failed - \(error.localizedDescription)")
		}
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
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		applyContext(message)
	}
	
	private func applyContext(_ context: [String: Any]) {
		guard
			let data = context[ConnectivityKey.payload] as? Data,
			let decoded = try? decoder.decode(PhoneState.self, from: data)
		else { return }
		
		Task { @MainActor in
			if let currentState = self.phoneState, decoded.updatedAt <= currentState.updatedAt {
				return
			}
			
			let isInitialLoad = self.phoneState == nil
			let previousFailure = self.phoneState?.commandFailedAt
			
			self.phoneState = decoded
			
			if !isInitialLoad, let failedAt = decoded.commandFailedAt, failedAt != previousFailure {
				self.flashFailureToast()
			}
		}
	}
	
	private func flashFailureToast() {
		showError = true
		errorClearTask?.cancel()
		errorClearTask = Task {
			try? await Task.sleep(for: .seconds(1))
			guard !Task.isCancelled else { return }
			await MainActor.run { self.showError = false }
		}
	}
}
