import Foundation

struct BlockedApp: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var appBundleId: String
    var appName: String
    var isEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case appBundleId = "app_bundle_id"
        case appName = "app_name"
        case isEnabled = "is_enabled"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        appBundleId: String,
        appName: String,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.appBundleId = appBundleId
        self.appName = appName
        self.isEnabled = isEnabled
    }
}

// Common apps that users might want to block
struct CommonBlockableApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let icon: String
    
    static let all: [CommonBlockableApp] = [
        CommonBlockableApp(name: "Instagram", bundleId: "com.burbn.instagram", icon: "camera"),
        CommonBlockableApp(name: "TikTok", bundleId: "com.zhiliaoapp.musically", icon: "music.note"),
        CommonBlockableApp(name: "Twitter / X", bundleId: "com.twitter.twitter", icon: "bubble.left"),
        CommonBlockableApp(name: "YouTube", bundleId: "com.google.ios.youtube", icon: "play.rectangle"),
        CommonBlockableApp(name: "Reddit", bundleId: "com.reddit.Reddit", icon: "text.bubble"),
        CommonBlockableApp(name: "Netflix", bundleId: "com.netflix.Netflix", icon: "tv"),
        CommonBlockableApp(name: "Facebook", bundleId: "com.facebook.Facebook", icon: "person.2"),
        CommonBlockableApp(name: "Snapchat", bundleId: "com.toyopagroup.picaboo", icon: "camera.viewfinder"),
        CommonBlockableApp(name: "Discord", bundleId: "com.hammerandchisel.discord", icon: "message"),
        CommonBlockableApp(name: "Twitch", bundleId: "tv.twitch", icon: "gamecontroller")
    ]
}
