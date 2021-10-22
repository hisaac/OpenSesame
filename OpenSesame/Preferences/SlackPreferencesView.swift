import Defaults
import Foundation
import Preferences
import SwiftUI

/// The Slack preferences pane
struct SlackPreferencesView: View {
	@State private var newSubdomain: String?
	@Default(.slackTeams) private var slackTeams
	@Default(.handleSlackURLs) private var handleSlackURLs

	var body: some View {
		Preferences.Section(title: "Slack Preferences") {
			Toggle("Allow Open Sesame to handle Slack links", isOn: $handleSlackURLs)
		}
	}
}

struct SlackPreferencesView_Previews: PreviewProvider {
	static var previews: some View {
		SlackPreferencesView()
	}
}
