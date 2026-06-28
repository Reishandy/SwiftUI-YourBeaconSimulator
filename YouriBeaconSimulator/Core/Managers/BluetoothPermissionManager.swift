//
//  BluetoothPermissionManager.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

import CoreBluetooth
import Observation

@Observable
@MainActor
public final class BluetoothPermissionManager: NSObject, CBPeripheralManagerDelegate {
	public private(set) var authorization: CBManagerAuthorization = CBPeripheralManager.authorization
	public private(set) var state: CBManagerState = .unknown
	
	private var dummyManager: CBPeripheralManager?
	private var authContinuation: CheckedContinuation<CBManagerAuthorization, Never>?
	
	public override init() {
		super.init()
		if CBPeripheralManager.authorization != .notDetermined {
			self.dummyManager = CBPeripheralManager(delegate: self, queue: nil, options: [
				CBPeripheralManagerOptionShowPowerAlertKey: false
			])
		}
	}
	
	public func requestPermission() async -> CBManagerAuthorization {
		guard authorization == .notDetermined else { return authorization }
		
		return await withCheckedContinuation { continuation in
			self.authContinuation = continuation
			self.dummyManager = CBPeripheralManager(delegate: self, queue: nil, options: [
				CBPeripheralManagerOptionShowPowerAlertKey: true
			])
		}
	}
	
	public nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		Task { @MainActor in
			self.state = peripheral.state
			self.authorization = CBPeripheralManager.authorization
			
			if CBPeripheralManager.authorization != .notDetermined, let continuation = self.authContinuation {
				continuation.resume(returning: CBPeripheralManager.authorization)
				self.authContinuation = nil
			}
		}
	}
}
