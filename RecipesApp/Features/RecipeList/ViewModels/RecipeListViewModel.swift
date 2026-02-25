import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class RecipeListViewModel {
    var recipes: [Recipe] = []
    var filteredRecipes: [Recipe] = []
    var isLoading = false
    var error: Error?
    var hasMorePages = true
    var searchQuery = ""
    var filterOptions = FilterOptions()

    private var currentPage = 1
    private let pageSize = Configuration.defaultPageSize
    private let recipeService: RecipeService
    private let debouncer = Debouncer(delay: 0.3)

    init(modelContext: ModelContext) {
        self.recipeService = RecipeService(modelContext: modelContext)
    }

    func loadRecipes() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let (fetchedRecipes, pagination) = try await recipeService.fetchRecipes(page: 1, limit: pageSize)
            recipes = fetchedRecipes
            currentPage = 1
            hasMorePages = pagination.page < pagination.totalPages

            await applyFilters()
        } catch {
            self.error = error
            print("Failed to load recipes: \(error)")
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard !isLoading && hasMorePages else { return }

        isLoading = true

        do {
            let nextPage = currentPage + 1
            let (fetchedRecipes, pagination) = try await recipeService.fetchRecipes(page: nextPage, limit: pageSize)

            recipes.append(contentsOf: fetchedRecipes)
            currentPage = nextPage
            hasMorePages = pagination.page < pagination.totalPages

            await applyFilters()
        } catch {
            self.error = error
            print("Failed to load next page: \(error)")
        }

        isLoading = false
    }

    func refresh() async {
        currentPage = 1
        hasMorePages = true
        await loadRecipes()

        await Task { @MainActor in
            await HapticService.shared.notification(.success)
        }.value
    }

    func search(query: String) {
        searchQuery = query
        debouncer.debounce {
            await self.applyFilters()
        }
    }

    func applyFilter(_ options: FilterOptions) async {
        filterOptions = options
        await applyFilters()
    }

    private func applyFilters() async {
        var filtered = recipes

        // Text search
        if !searchQuery.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchQuery) ||
                recipe.recipeDescription?.localizedCaseInsensitiveContains(searchQuery) == true ||
                recipe.ingredients.contains {
                    $0.localizedCaseInsensitiveContains(searchQuery)
                }
            }
        }

        // Difficulty filter
        if let difficulty = filterOptions.difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        // Sort
        switch filterOptions.sortBy {
        case .dateNewest:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dateOldest:
            filtered.sort { $0.createdAt < $1.createdAt }
        case .titleAZ:
            filtered.sort { $0.title < $1.title }
        case .titleZA:
            filtered.sort { $0.title > $1.title }
        }

        filteredRecipes = filtered
    }
}
