//
//  BroadcastSectionHeaderView.swift
//  YouriBeaconSimulator
//
//  Created by Muhammad Akbar Reishandy on 25/06/26.
//

import SwiftUI

struct BroadcastSectionHeaderView: View {
    var body: some View {
		VStack(alignment: .leading) {
			Text("Group name")
				.font(.title3)
				.bold()
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			
			HStack {
				Text(UUID().uuidString)
					.font(.callout.monospaced())
					.opacity(0.8)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
				
				Spacer()
				
				Image(systemName: "document.on.document")
					.font(.footnote)
			}
			.onTapGesture {
				// TODO: Copy
			}
		}
    }
}

#Preview {
    BroadcastSectionHeaderView()
}
