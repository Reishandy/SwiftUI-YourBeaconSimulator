//
//  BroadcastFormView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI
import SwiftData

struct BroadcastFormView: View {
	@Binding var selectedProject: BroadcastProject?
	@Binding var projectName: String
	@Binding var proximityUUID: String
	
	@Binding var beaconName: String
	@Binding var majorID: Int?
	@Binding var minorID: Int?
	
	var availableProjects: [BroadcastProject]
	
	var body: some View {
		Form {
			Section() {
				Picker("Project", selection: $selectedProject) {
					Text("Input new project").tag(BroadcastProject?(nil))
					
					ForEach(availableProjects) { project in
						Text(project.name).tag(BroadcastProject?(project))
					}
				}
				.onChange(of: selectedProject) { _, newValue in
					if let project = newValue {
						projectName = project.name
						proximityUUID = project.proximityUUID
					} else {
						projectName = ""
						proximityUUID = ""
					}
				}
				
				TextField("Project Name", text: $projectName)
				
				HStack {
					TextField("Proximity UUID", text: $proximityUUID)
					
					Button {
						proximityUUID = UUID().uuidString
					} label: {
						Image(systemName: "arrow.triangle.2.circlepath")
							.font(.callout)
					}
					.buttonStyle(.plain)
				}
			} footer: {
				if selectedProject != nil {
					Text("Editing an existing project's name or UUID will apply these changes to all beacons linked to this project.")
				}
			}
			
			Section() {
				TextField("Beacon Name", text: $beaconName)
				
				HStack {
#if os(iOS)
					Text("Major:")
#endif
					
					TextField("Major ID", text: Binding(
						get: { majorID.map(String.init) ?? "" },
						set: { majorID = Int($0) }
					))
#if os(iOS)
					.keyboardType(.numberPad)
#endif
				}
				
				HStack {
#if os(iOS)
					Text("Major:")
#endif
					
					TextField("Minor ID", text: Binding(
						get: { minorID.map(String.init) ?? "" },
						set: { minorID = Int($0) }
					))
#if os(iOS)
					.keyboardType(.numberPad)
#endif
				}
			}
		}
#if os(macOS)
		.padding(.horizontal, 20)
#endif
	}
}

#Preview {
	BroadcastFormView(
		selectedProject: .constant(nil),
		projectName: .constant(""),
		proximityUUID: .constant(""),
		beaconName: .constant(""),
		majorID: .constant(nil),
		minorID: .constant(nil),
		availableProjects: [
			BroadcastProject(name: "Office Setup", proximityUUID: UUID().uuidString),
			BroadcastProject(name: "Home Lab", proximityUUID: UUID().uuidString)
		]
	)
}
