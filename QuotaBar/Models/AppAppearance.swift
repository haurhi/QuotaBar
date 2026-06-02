import Combine
import Foundation

final class AppAppearanceStore: ObservableObject {
    static let shared = AppAppearanceStore()
    static let statusBarTransparencyKey = "statusBarTransparency"

    @Published var statusBarTransparency: Double {
        didSet {
            let value = Self.clamped(statusBarTransparency)
            if value != statusBarTransparency {
                statusBarTransparency = value
                return
            }
            defaults.set(value, forKey: Self.statusBarTransparencyKey)
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Self.statusBarTransparencyKey) == nil {
            statusBarTransparency = 0.58
        } else {
            statusBarTransparency = Self.clamped(defaults.double(forKey: Self.statusBarTransparencyKey))
        }
    }

    private static func clamped(_ value: Double) -> Double {
        min(max(value, 0.10), 0.95)
    }
}
