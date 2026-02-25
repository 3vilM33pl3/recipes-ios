import Foundation

// MARK: - API Response Models

struct RecipeListResponse: Codable, Sendable {
    let recipes: [RecipeDTO]
    let pagination: PaginationInfo
}

struct PaginationInfo: Codable, Sendable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

struct RecipeUploadResponse: Codable, Sendable {
    let success: Bool
    let recipe: RecipeUploadInfo?
    let error: String?
}

struct RecipeUploadInfo: Codable, Sendable {
    let id: String
    let slug: String
    let title: String
    let url: String
    let qrUrl: String
}

struct RecipeDeleteResponse: Codable, Sendable {
    let success: Bool
    let message: String?
}

// MARK: - Error Models

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int, String?)
    case uploadFailed(String)
    case notFound
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .notFound:
            return "Recipe not found"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

// MARK: - Filter & Sort Options

struct FilterOptions: Sendable {
    var difficulty: String?
    var sortBy: SortOption = .dateNewest

    enum SortOption: Sendable {
        case dateNewest
        case dateOldest
        case titleAZ
        case titleZA
    }
}
