import Foundation
import SwiftData

@Model
final class Recipe: Identifiable, @unchecked Sendable {
    @Attribute(.unique) var id: String
    @Attribute(.unique) var slug: String
    var title: String
    var recipeDescription: String?
    var servings: String?
    var prepTime: String?
    var cookTime: String?
    var difficulty: String?
    var ingredients: [String]
    var instructions: [String]
    var nutrition: String?
    var notes: String?
    var thumbnailImage: String?
    var qrCodeImage: String?
    var originalImage: String?
    var createdAt: Date
    var updatedAt: Date?

    // Computed properties for URLs
    var thumbnailURL: URL? {
        guard let filename = thumbnailImage else { return nil }
        return Configuration.baseURL.appendingPathComponent("thumbnails/\(filename)")
    }

    var originalImageURL: URL? {
        guard let filename = originalImage else { return nil }
        return Configuration.baseURL.appendingPathComponent("uploads/\(filename)")
    }

    var qrCodeURL: URL? {
        guard let filename = qrCodeImage else { return nil }
        return Configuration.baseURL.appendingPathComponent("qr/\(filename)")
    }

    var recipeURL: URL {
        Configuration.baseURL.appendingPathComponent("r/\(slug)")
    }

    init(
        id: String,
        slug: String,
        title: String,
        recipeDescription: String? = nil,
        servings: String? = nil,
        prepTime: String? = nil,
        cookTime: String? = nil,
        difficulty: String? = nil,
        ingredients: [String] = [],
        instructions: [String] = [],
        nutrition: String? = nil,
        notes: String? = nil,
        thumbnailImage: String? = nil,
        qrCodeImage: String? = nil,
        originalImage: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.recipeDescription = recipeDescription
        self.servings = servings
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutrition = nutrition
        self.notes = notes
        self.thumbnailImage = thumbnailImage
        self.qrCodeImage = qrCodeImage
        self.originalImage = originalImage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Share Support
extension Recipe {
    func shareItems() -> [Any] {
        var items: [Any] = []

        // Recipe URL
        items.append(recipeURL)

        // Recipe text
        var text = title
        if let description = recipeDescription {
            text += "\n\n\(description)"
        }
        text += "\n\nView full recipe: \(recipeURL.absoluteString)"
        items.append(text)

        return items
    }
}

// MARK: - Recipe DTO (for API communication)

struct RecipeDTO: Codable, Sendable {
    let id: String
    let slug: String
    let title: String
    let description: String?
    let servings: String?
    let prepTime: String?
    let cookTime: String?
    let difficulty: String?
    let ingredients: [String]?
    let instructions: [String]?
    let nutrition: String?
    let notes: String?
    let thumbnailImage: String?
    let qrCodeImage: String?
    let originalImage: String?
    let createdAt: String?
    let updatedAt: String?

    func toRecipe() -> Recipe {
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = createdAt.flatMap { dateFormatter.date(from: $0) } ?? Date()
        let updatedDate = updatedAt.flatMap { dateFormatter.date(from: $0) }

        return Recipe(
            id: id,
            slug: slug,
            title: title,
            recipeDescription: description,
            servings: servings,
            prepTime: prepTime,
            cookTime: cookTime,
            difficulty: difficulty,
            ingredients: ingredients ?? [],
            instructions: instructions ?? [],
            nutrition: nutrition,
            notes: notes,
            thumbnailImage: thumbnailImage,
            qrCodeImage: qrCodeImage,
            originalImage: originalImage,
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}
