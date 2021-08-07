import Defaults
import LSFoundation
import SwiftUI

final class SlackHandler: URLHandler {
	weak var delegate: URLHandlerDelegate?

	func canHandle(_ url: URL) -> Bool {
		guard Defaults[.handleSlackURLs],
			  let host = url.host else {
			return false
		}

		guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
			  let queryItems = urlComponents.queryItems else {
			return false
		}

		let isSlackAppURL = host.hasSuffix("slack.com")

		// TODO: Actually figure this out
		// Will have to have user provide details about their Slack instance for URLs
		// Provide URL prefix, then
		// https://stackoverflow.com/a/64098359/4118208
		// You can open a specific message using:
		// slack://channel?team=<team id>&id=<channel id>&thread_ts=<ts>
		return false
	}

	func handle(_ url: URL) {
		guard let subdomain = getSlackSubdomain(from: url) else {
			delegate?.open(url, usingFallbackHandler: true)
			return
		}
//		// TODO: Figure out modification of URL necessary (slack://) https://api.slack.com/reference/deep-linking
//		delegate?.open(url: url, usingApplicationWithBundleIdentifier: URLOpener.KnownBundleIdentifier.slack.rawValue)

		if doesSlackTeamAlreadyExist(forSubdomain: subdomain),
		   let slackAppURL = constructSlackAppURL(from: url) {

		} else {
			// open Slack team preferences pane
		}
	}

	private func doesSlackTeamAlreadyExist(forSubdomain subdomain: String) -> Bool {
		guard let slackTeams = Defaults[.slackTeams] else { return false }
		return slackTeams.contains { $0.subdomain == subdomain }
	}

	private func constructSlackAppURL(from url: URL) -> URL? {
		return nil
	}

	private func getSlackSubdomain(from url: URL) -> String? {
		guard let host = url.host else { return nil }
		return host.replacingOccurrences(of: "slack.com", with: "")
	}
}
