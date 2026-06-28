//
//  LocationPermissionManager.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 28/06/26.
//

import CoreLocation
import Observation

@Observable
@MainActor
public final class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
	private let locationManager = CLLocationManager()
	
	public private(set) var authorizationStatus: CLAuthorizationStatus
	private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
	
	public override init() {
		self.authorizationStatus = locationManager.authorizationStatus
		super.init()
		self.locationManager.delegate = self
	}
	
	public func requestWhenInUse() async -> CLAuthorizationStatus {
		guard authorizationStatus == .notDetermined else { return authorizationStatus }
		
		return await withCheckedContinuation { continuation in
			self.authContinuation = continuation
			self.locationManager.requestWhenInUseAuthorization()
		}
	}
	
	public func requestAlways() async -> CLAuthorizationStatus {
		guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .notDetermined else {
			return authorizationStatus
		}
		
		return await withCheckedContinuation { continuation in
			self.authContinuation = continuation
			self.locationManager.requestAlwaysAuthorization()
		}
	}
	
	public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		Task { @MainActor in
			self.authorizationStatus = manager.authorizationStatus
			
			if let continuation = self.authContinuation {
				continuation.resume(returning: manager.authorizationStatus)
				self.authContinuation = nil
			}
		}
	}
}
