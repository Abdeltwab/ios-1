import Foundation
import Models
import Utils

public struct SettingsState {
    public var preferences: Loadable<UserPreferences>

    public init(preferences: Loadable<UserPreferences>) {
        self.preferences = preferences
    }
}
