import Foundation
import SwiftData

@MainActor
class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        let schema = Schema([
            Recipe.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Preview Support

    static var preview: PersistenceController {
        let controller = PersistenceController()

        // Add sample data for previews
        let context = controller.container.mainContext

        let sampleRecipe = Recipe(
            id: "preview-1",
            slug: "sample-recipe",
            title: "Sample Recipe",
            recipeDescription: "A delicious sample recipe for preview",
            servings: "4",
            prepTime: "15 minutes",
            cookTime: "30 minutes",
            difficulty: "Easy",
            ingredients: [
                "2 cups flour",
                "1 cup sugar",
                "3 eggs",
                "1/2 cup butter"
            ],
            instructions: [
                "Preheat oven to 350°F",
                "Mix dry ingredients",
                "Add wet ingredients",
                "Bake for 30 minutes"
            ]
        )

        context.insert(sampleRecipe)

        return controller
    }
}

// MARK: - Cache Manager

actor CacheManager {
    static let shared = CacheManager()

    private var recipeCache: [String: CachedRecipe] = [:]

    struct CachedRecipe: Sendable {
        let recipe: Recipe
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > Configuration.recipeCacheMaxAge
        }
    }

    func cacheRecipe(_ recipe: Recipe) {
        recipeCache[recipe.slug] = CachedRecipe(recipe: recipe, timestamp: Date())
    }

    func getCachedRecipe(slug: String) -> Recipe? {
        guard let cached = recipeCache[slug], !cached.isExpired else {
            recipeCache.removeValue(forKey: slug)
            return nil
        }
        return cached.recipe
    }

    func clearExpiredCache() {
        recipeCache = recipeCache.filter { !$0.value.isExpired }
    }

    func clearAllCache() {
        recipeCache.removeAll()
    }
}
