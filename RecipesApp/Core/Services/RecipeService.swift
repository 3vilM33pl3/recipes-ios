import Foundation
import SwiftData
import UIKit

@MainActor
class RecipeService: ObservableObject {
    @Published var isOnline = true

    private let networkManager = NetworkManager.shared
    private let cacheManager = CacheManager.shared
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch Recipes

    func fetchRecipes(page: Int, limit: Int) async throws -> (recipes: [Recipe], pagination: PaginationInfo) {
        do {
            let response: RecipeListResponse = try await networkManager.request(
                endpoint: .recipes(page: page, limit: limit),
                method: .get
            )

            // Convert DTOs to models and cache
            let recipes = response.recipes.map { $0.toRecipe() }
            for recipe in recipes {
                cacheRecipe(recipe)
            }

            isOnline = true
            return (recipes: recipes, pagination: response.pagination)

        } catch {
            isOnline = false

            // Try to fetch from local cache
            return try await fetchCachedRecipes(page: page, limit: limit)
        }
    }

    // MARK: - Fetch Recipe Detail

    func fetchRecipeDetail(slug: String) async throws -> Recipe {
        do {
            let recipeDTO: RecipeDTO = try await networkManager.request(
                endpoint: .recipeDetail(slug: slug),
                method: .get
            )

            let recipe = recipeDTO.toRecipe()
            cacheRecipe(recipe)
            isOnline = true

            return recipe

        } catch {
            isOnline = false

            // Try to fetch from SwiftData
            let descriptor = FetchDescriptor<Recipe>(
                predicate: #Predicate { $0.slug == slug }
            )

            guard let cachedRecipe = try modelContext.fetch(descriptor).first else {
                throw APIError.notFound
            }

            return cachedRecipe
        }
    }

    // MARK: - Upload Recipe

    func uploadRecipe(_ imageData: Data) async throws -> RecipeUploadInfo {
        // Compress image if needed
        let compressedData = try await compressImage(imageData)

        let fileName = "recipe-\(UUID().uuidString).jpg"

        let response = try await networkManager.uploadMultipart(
            imageData: compressedData,
            fileName: fileName,
            mimeType: "image/jpeg"
        )

        guard response.success, let recipeInfo = response.recipe else {
            throw APIError.uploadFailed(response.error ?? "Unknown error")
        }

        return recipeInfo
    }

    // MARK: - Delete Recipe

    func deleteRecipe(slug: String) async throws {
        let response = try await networkManager.delete(
            endpoint: .deleteRecipe(slug: slug)
        )

        guard response.success else {
            throw APIError.serverError(500, response.message)
        }

        // Remove from local cache
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.slug == slug }
        )

        if let recipe = try? modelContext.fetch(descriptor).first {
            modelContext.delete(recipe)
            try? modelContext.save()
        }
    }

    // MARK: - Private Helpers

    private func cacheRecipe(_ recipe: Recipe) {
        // Cache in SwiftData
        let recipeId = recipe.id
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.id == recipeId }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            // Update existing
            existing.title = recipe.title
            existing.recipeDescription = recipe.recipeDescription
            existing.servings = recipe.servings
            existing.prepTime = recipe.prepTime
            existing.cookTime = recipe.cookTime
            existing.difficulty = recipe.difficulty
            existing.ingredients = recipe.ingredients
            existing.instructions = recipe.instructions
            existing.nutrition = recipe.nutrition
            existing.notes = recipe.notes
            existing.thumbnailImage = recipe.thumbnailImage
            existing.qrCodeImage = recipe.qrCodeImage
            existing.originalImage = recipe.originalImage
            existing.updatedAt = Date()
        } else {
            // Insert new
            modelContext.insert(recipe)
        }

        try? modelContext.save()
    }

    private func fetchCachedRecipes(page: Int, limit: Int) async throws -> (recipes: [Recipe], pagination: PaginationInfo) {
        let offset = (page - 1) * limit

        var descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        let recipes = try modelContext.fetch(descriptor)

        // Get total count
        let countDescriptor = FetchDescriptor<Recipe>()
        let total = try modelContext.fetchCount(countDescriptor)

        let pagination = PaginationInfo(
            page: page,
            limit: limit,
            total: total,
            totalPages: Int(ceil(Double(total) / Double(limit)))
        )

        return (recipes: recipes, pagination: pagination)
    }

    private func compressImage(_ imageData: Data) async throws -> Data {
        guard imageData.count > Configuration.maxImageUploadSize else {
            return imageData
        }

        return try await Task.detached {
            guard let image = UIImage(data: imageData) else {
                throw APIError.uploadFailed("Invalid image data")
            }

            var compression: CGFloat = Configuration.compressionQuality
            var compressedData = image.jpegData(compressionQuality: compression)

            while let data = compressedData, data.count > Configuration.maxImageUploadSize && compression > 0.1 {
                compression -= 0.1
                compressedData = image.jpegData(compressionQuality: compression)
            }

            guard let finalData = compressedData else {
                throw APIError.uploadFailed("Failed to compress image")
            }

            return finalData
        }.value
    }
}
