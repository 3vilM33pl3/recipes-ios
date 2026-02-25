import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class RecipeDetailViewModel {
    var recipe: Recipe?
    var isLoading = false
    var error: Error?
    var showDeleteConfirmation = false
    var didDelete = false

    private let slug: String
    private let recipeService: RecipeService

    init(slug: String, modelContext: ModelContext) {
        self.slug = slug
        self.recipeService = RecipeService(modelContext: modelContext)
    }

    func loadRecipe() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            recipe = try await recipeService.fetchRecipeDetail(slug: slug)
        } catch {
            self.error = error
            print("Failed to load recipe: \(error)")
        }

        isLoading = false
    }

    func deleteRecipe() async {
        do {
            try await recipeService.deleteRecipe(slug: slug)
            didDelete = true

            await HapticService.shared.notification(.success)
        } catch {
            self.error = error
            print("Failed to delete recipe: \(error)")

            await HapticService.shared.notification(.error)
        }
    }

    func shareRecipe() -> [Any] {
        recipe?.shareItems() ?? []
    }
}
