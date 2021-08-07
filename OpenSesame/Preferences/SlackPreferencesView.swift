import Defaults
import Preferences
import SwiftUI

extension Preferences.PaneIdentifier {
	static let slack = Self("slack")
}

/// The Slack preferences pane
struct SlackPreferencesView: View {
	@State private var newSubdomain: String?
	@Default(.slackTeams) private var slackTeams

	var body: some View {
		Preferences.Container(contentWidth: 480) {
			Preferences.Section(title: "Slack Teams") {

			}
		}
	}
}

struct SlackPreferencesView_Previews: PreviewProvider {
	static var previews: some View {
		SlackPreferencesView()
	}
}
