import Foundation

enum Configuration {
    static let baseURL = URL(string: "https://recipes.metatao.net")!
    static let apiVersion = "v1"
    static let bundleIdentifier = "net.metatao.recipes"

    // Pagination
    static let defaultPageSize = 20
    static let maxPageSize = 50

    // Cache
    static let imageCacheMaxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    static let recipeCacheMaxAge: TimeInterval = 24 * 60 * 60 // 24 hours
    static let maxCacheSize: Int = 100 * 1024 * 1024 // 100 MB

    // Network
    static let requestTimeout: TimeInterval = 30
    static let uploadTimeout: TimeInterval = 120

    // Image
    static let maxImageUploadSize: Int = 10 * 1024 * 1024 // 10 MB
    static let compressionQuality: CGFloat = 0.8

    // UI
    static let gridColumns = 2
    static let cornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
}
