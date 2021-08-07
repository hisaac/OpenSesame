import Defaults
import Preferences
import SwiftUI

extension Preferences.PaneIdentifier {
	static let general = Self("general")
}

/// The General preferences pane
struct GeneralPreferencesView: View {
	@Default(.urlHandlingEnabled) var urlHandlingEnabled
	@Default(.showMenuItem) var showMenuItem
	@Default(.statusItemLeftClickBehavior) var statusItemLeftClickBehavior
	@Default(.defaultFallbackBrowserBundleIdentifier) var defaultFallbackBrowserBundleIdentifier

	private let htmlHandlers = OSLaunchServices.getHTMLHandlers()

	var body: some View {
		Preferences.Container(contentWidth: 480) {
			Preferences.Section(title: "URL Handling:") {
				Toggle("Enable URL handling", isOn: $urlHandlingEnabled)
			}
			Preferences.Section(title: "Menu item:") {
				Toggle("Show menu item", isOn: $showMenuItem)
				Text("When the menu item is hidden, launching the app will bring up this preferences window")
					.preferenceDescription()
					.padding(.trailing, 10)
				Picker(selection: $statusItemLeftClickBehavior, label: EmptyView()) {
					Text("Clicking opens menu").tag(StatusItemLeftClickBehavior.openMenu)
					Text("Clicking toggles clipboard filtering").tag(StatusItemLeftClickBehavior.toggleFiltering)
				}
				.pickerStyle(RadioGroupPickerStyle())
				.disabled(showMenuItem)

				Text("Right-clicking will do the opposite of what's selected")
					.preferenceDescription()
			}
			Preferences.Section(title: "Default browser:") {
				Picker(selection: $defaultFallbackBrowserBundleIdentifier, label: EmptyView()) {
					ForEach(htmlHandlers, id: \.bundleIdentifier) { handler in
						if let infoDictionary = handler.infoDictionary,
						   let appName = infoDictionary["CFBundleDisplayName"] as? String {
							Text(appName)
						}
					}
				}
			}
		}
	}
}

struct GeneralPreferencesView_Previews: PreviewProvider {
	static var previews: some View {
		GeneralPreferencesView()
	}
}
