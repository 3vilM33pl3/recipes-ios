import XCTest
import SwiftData
@testable import RecipesApp

@MainActor
final class RecipeListViewModelTests: XCTestCase {
    var modelContext: ModelContext!
    var viewModel: RecipeListViewModel!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([Recipe.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        modelContext = ModelContext(container)

        viewModel = RecipeListViewModel(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        modelContext = nil
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.filteredRecipes.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.searchQuery, "")
    }

    func testSearchFiltering() async throws {
        // Add test recipes
        let recipe1 = Recipe(
            id: "1",
            slug: "chocolate-cake",
            title: "Chocolate Cake",
            ingredients: ["chocolate", "flour", "sugar"]
        )
        let recipe2 = Recipe(
            id: "2",
            slug: "vanilla-cake",
            title: "Vanilla Cake",
            ingredients: ["vanilla", "flour", "sugar"]
        )

        viewModel.recipes = [recipe1, recipe2]
        viewModel.filteredRecipes = [recipe1, recipe2]

        // Test search
        viewModel.search(query: "chocolate")

        // Wait for debouncer
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        XCTAssertEqual(viewModel.filteredRecipes.count, 1)
        XCTAssertEqual(viewModel.filteredRecipes.first?.title, "Chocolate Cake")
    }

    func testDifficultyFiltering() async throws {
        // Add test recipes with different difficulties
        let easyRecipe = Recipe(
            id: "1",
            slug: "easy-recipe",
            title: "Easy Recipe",
            difficulty: "Easy"
        )
        let hardRecipe = Recipe(
            id: "2",
            slug: "hard-recipe",
            title: "Hard Recipe",
            difficulty: "Hard"
        )

        viewModel.recipes = [easyRecipe, hardRecipe]
        viewModel.filteredRecipes = [easyRecipe, hardRecipe]

        // Apply difficulty filter
        var filterOptions = FilterOptions()
        filterOptions.difficulty = "Easy"
        await viewModel.applyFilter(filterOptions)

        XCTAssertEqual(viewModel.filteredRecipes.count, 1)
        XCTAssertEqual(viewModel.filteredRecipes.first?.difficulty, "Easy")
    }

    func testSorting() async throws {
        let recipe1 = Recipe(
            id: "1",
            slug: "zebra",
            title: "Zebra Cake",
            createdAt: Date().addingTimeInterval(-86400) // 1 day ago
        )
        let recipe2 = Recipe(
            id: "2",
            slug: "apple",
            title: "Apple Pie",
            createdAt: Date() // Now
        )

        viewModel.recipes = [recipe1, recipe2]
        viewModel.filteredRecipes = [recipe1, recipe2]

        // Test sort by title A-Z
        var filterOptions = FilterOptions()
        filterOptions.sortBy = .titleAZ
        await viewModel.applyFilter(filterOptions)

        XCTAssertEqual(viewModel.filteredRecipes.first?.title, "Apple Pie")

        // Test sort by date newest
        filterOptions.sortBy = .dateNewest
        await viewModel.applyFilter(filterOptions)

        XCTAssertEqual(viewModel.filteredRecipes.first?.title, "Apple Pie")

        // Test sort by date oldest
        filterOptions.sortBy = .dateOldest
        await viewModel.applyFilter(filterOptions)

        XCTAssertEqual(viewModel.filteredRecipes.first?.title, "Zebra Cake")
    }
}
