import Foundation
import Preferences
import SwiftUI

extension Preferences.PaneIdentifier {
	static let urlHandlers = Self("urlHandlers")
}

struct URLHandlerPreferencesView: View {

	private var array = ["Browsers", "Shortlinks", "Slack"]
	@State private var selectedOption = "Browsers"

	var body: some View {
		Preferences.Container(contentWidth: 480) {
			Preferences.Section(title: "blah") {
				List {
					ForEach(array, id: \.description) {
						Text($0)
					}
				}
			}
			Preferences.Section(title: "URL Handler Preferences") {
				Picker(selection: $selectedOption, label: EmptyView()) {
					ForEach(array, id: \.description) {
						Text($0)
					}
				}
//				.pickerStyle(.inline)
			}
		}
	}
}

struct URLHandlerPreferencesView_Previews: PreviewProvider {
	static var previews: some View {
		URLHandlerPreferencesView()
	}
}
