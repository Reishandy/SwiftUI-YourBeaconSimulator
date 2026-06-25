//
//  BroadcastAddSheetView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI
import SwiftData

struct BroadcastAddSheetView: View {
	@Binding var selectedProject: BroadcastProject?
	@Binding var projectName: String
	@Binding var proximityUUID: String
	
	@Binding var beaconName: String
	@Binding var majorID: Int?
	@Binding var minorID: Int?
	
	var availableProjects: [BroadcastProject]
	
	let onDismissClick: () -> Void
	let onSaveClick: () -> Void
	
	@State private var isDismissConfirmationShown: Bool = false
	
	private var isFormFilled: Bool {
		let isBeaconValid = !beaconName.trimmingCharacters(in: .whitespaces).isEmpty && majorID != nil && minorID != nil
		
		let isUUIDValid = UUID(uuidString: proximityUUID) != nil
		
		let isProjectValid = !projectName.trimmingCharacters(in: .whitespaces).isEmpty && isUUIDValid
		
		return isBeaconValid && isProjectValid
	}
	
	private var isFormDirty: Bool {
		selectedProject != nil ||
		!projectName.trimmingCharacters(in: .whitespaces).isEmpty ||
		!proximityUUID.trimmingCharacters(in: .whitespaces).isEmpty ||
		!beaconName.trimmingCharacters(in: .whitespaces).isEmpty ||
		majorID != nil ||
		minorID != nil
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
			.navigationTitle("Add New Beacon")
			.navigationTitle("Add New Beacon")
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
						Text("Are you sure you want to discard this?")
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						onSaveClick()
					}
					.disabled(!isFormFilled)
				}
			}
		}
		.interactiveDismissDisabled()
		.presentationDetents([.large])
	}
}

#Preview {
	BroadcastAddSheetView(
		selectedProject: .constant(nil),
		projectName: .constant(""),
		proximityUUID: .constant(""),
		beaconName: .constant(""),
		majorID: .constant(nil),
		minorID: .constant(nil),
		availableProjects: [],
		onDismissClick: {},
		onSaveClick: {}
	)
}
