//
//  BroadcastEditSheetView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI
import SwiftData

struct BroadcastEditSheetView: View {
	let beacon: BroadcastBeacon
	var availableProjects: [BroadcastProject]
	let onDismissClick: () -> Void
	
	let onSaveClick: (_ selectedProject: BroadcastProject?, _ projectName: String, _ proximityUUID: String, _ beaconName: String, _ major: Int, _ minor: Int) -> Void
	
	@State private var selectedProject: BroadcastProject?
	@State private var projectName: String
	@State private var proximityUUID: String
	
	@State private var beaconName: String
	@State private var majorID: Int?
	@State private var minorID: Int?
	
	@State private var isDismissConfirmationShown: Bool = false
	
	init(
		beacon: BroadcastBeacon,
		availableProjects: [BroadcastProject],
		onDismissClick: @escaping () -> Void,
		onSaveClick: @escaping (_ selectedProject: BroadcastProject?, _ projectName: String, _ proximityUUID: String, _ beaconName: String, _ major: Int, _ minor: Int) -> Void
	) {
		self.beacon = beacon
		self.availableProjects = availableProjects
		self.onDismissClick = onDismissClick
		self.onSaveClick = onSaveClick
		
		_selectedProject = State(initialValue: beacon.project)
		_projectName = State(initialValue: beacon.project?.name ?? "")
		_proximityUUID = State(initialValue: beacon.project?.proximityUUID ?? "")
		
		_beaconName = State(initialValue: beacon.beaconName)
		_majorID = State(initialValue: beacon.majorID)
		_minorID = State(initialValue: beacon.minorID)
	}
	
	private var isFormFilled: Bool {
		let isBeaconValid = !beaconName.trimmingCharacters(in: .whitespaces).isEmpty && majorID != nil && minorID != nil
		let isUUIDValid = UUID(uuidString: proximityUUID) != nil
		let isProjectValid = !projectName.trimmingCharacters(in: .whitespaces).isEmpty && isUUIDValid
		
		return isBeaconValid && isProjectValid
	}
	
	private var isFormDirty: Bool {
		let beaconChanged = beacon.beaconName != beaconName || beacon.majorID != majorID || beacon.minorID != minorID
		
		let projectChanged = beacon.project != selectedProject ||
		(beacon.project?.name ?? "") != projectName ||
		(beacon.project?.proximityUUID ?? "") != proximityUUID
		
		let newProjectTyped = selectedProject == nil && (!projectName.trimmingCharacters(in: .whitespaces).isEmpty || !proximityUUID.trimmingCharacters(in: .whitespaces).isEmpty)
		
		return beaconChanged || projectChanged || newProjectTyped
	}
	
	var body: some View {
		NavigationStack {
			BroadcastFormView(
				selectedProject: $selectedProject,
				projectName: $projectName,
				proximityUUID: $proximityUUID,
				beaconName: $beaconName,
				majorID: $majorID,
				minorID: $minorID,
				availableProjects: availableProjects
			)
			.navigationTitle("Edit Beacon")
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Dismiss") {
						if isFormDirty {
							isDismissConfirmationShown = true
						} else {
							onDismissClick()
						}
					}
					.confirmationDialog(
						"Discard Change",
						isPresented: $isDismissConfirmationShown
					) {
						Button("Discard Change", role: .destructive) {
							onDismissClick()
						}
					} message: {
						Text("Are you sure you want to discard this edit?")
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						guard let major = majorID, let minor = minorID else { return }
						
						onSaveClick(selectedProject, projectName, proximityUUID, beaconName, major, minor)
					}
					.disabled(!isFormFilled)
				}
			}
		}
		.interactiveDismissDisabled()
		.presentationDetents([.large])
	}
}
