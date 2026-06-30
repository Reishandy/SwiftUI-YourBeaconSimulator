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
	
	static let validBeaconIDRange: ClosedRange<Int> = 1...65535
	
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
						.onChange(of: proximityUUID) { _, newValue in
							if let matchedProject = availableProjects.first(where: { $0.proximityUUID.caseInsensitiveCompare(newValue) == .orderedSame }) {
								if selectedProject != matchedProject {
									selectedProject = matchedProject
								}
							} else if selectedProject != nil && selectedProject?.proximityUUID.caseInsensitiveCompare(newValue) != .orderedSame {
								selectedProject = nil
							}
						}
					
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
					
					TextField("Major ID", text: sanitizedIDBinding(for: $majorID))
#if os(iOS)
					.keyboardType(.numberPad)
#endif
				}
				
				HStack {
#if os(iOS)
					Text("Minor:")
#endif
					
					TextField("Minor ID", text: sanitizedIDBinding(for: $minorID))
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
	
	private func sanitizedIDBinding(for value: Binding<Int?>) -> Binding<String> {
		Binding<String>(
			get: { value.wrappedValue.map(String.init) ?? "" },
			set: { newValue in
				let digitsOnly = newValue.filter(\.isNumber)
				
				guard !digitsOnly.isEmpty else {
					value.wrappedValue = nil
					return
				}
				
				let parsed = Int(digitsOnly) ?? Int.max
				value.wrappedValue = min(parsed, Self.validBeaconIDRange.upperBound)
			}
		)
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
