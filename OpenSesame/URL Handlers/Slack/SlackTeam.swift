import Defaults
import Foundation

struct SlackTeam: Hashable {
	let subdomain: String
	let teamID: String
}

// MARK: - Defaults implementation

extension SlackTeam: DefaultsSerializable {
	static let bridge = SlackTeamDefaultsBridge()
}

struct SlackTeamDefaultsBridge: Defaults.Bridge {
	typealias Value = SlackTeam
	typealias Serializable = [String: String]

	func serialize(_ value: SlackTeam?) -> [String: String]? {
		guard let value = value else { return nil }
		let serializedValue = [
			"subdomain": value.subdomain,
			"teamID": value.teamID
		]
		return serializedValue
	}

	func deserialize(_ object: [String: String]?) -> SlackTeam? {
		guard let object = object,
			  let subdomain = object["subdomain"],
			  let teamID = object["teamID"] else {
			return nil
		}

		let deserializedValue = SlackTeam(subdomain: subdomain, teamID: teamID)
		return deserializedValue
	}
}
