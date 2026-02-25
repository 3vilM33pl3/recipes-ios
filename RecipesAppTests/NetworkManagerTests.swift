import XCTest
@testable import RecipesApp

final class NetworkManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code before each test
    }

    override func tearDownWithError() throws {
        // Cleanup code after each test
    }

    func testAPIEndpointPaths() throws {
        // Test endpoint path generation
        let recipesEndpoint = APIEndpoint.recipes(page: 1, limit: 20)
        XCTAssertEqual(recipesEndpoint.path, "/api/recipes")

        let detailEndpoint = APIEndpoint.recipeDetail(slug: "test-recipe")
        XCTAssertEqual(detailEndpoint.path, "/api/recipes/test-recipe")

        let deleteEndpoint = APIEndpoint.deleteRecipe(slug: "test-recipe")
        XCTAssertEqual(deleteEndpoint.path, "/api/recipes/test-recipe")

        let qrEndpoint = APIEndpoint.qrCode(slug: "test-recipe")
        XCTAssertEqual(qrEndpoint.path, "/api/recipes/test-recipe/qr")
    }

    func testAPIEndpointQueryItems() throws {
        // Test query items generation
        let recipesEndpoint = APIEndpoint.recipes(page: 2, limit: 10)
        let queryItems = recipesEndpoint.queryItems

        XCTAssertNotNil(queryItems)
        XCTAssertEqual(queryItems?.count, 2)

        let pageItem = queryItems?.first { $0.name == "page" }
        XCTAssertEqual(pageItem?.value, "2")

        let limitItem = queryItems?.first { $0.name == "limit" }
        XCTAssertEqual(limitItem?.value, "10")
    }

    func testRecipeModelCoding() throws {
        // Test Recipe encoding/decoding
        let recipe = Recipe(
            id: "test-1",
            slug: "test-recipe",
            title: "Test Recipe",
            recipeDescription: "A test recipe",
            servings: "4",
            prepTime: "15 minutes",
            cookTime: "30 minutes",
            difficulty: "Easy",
            ingredients: ["Ingredient 1", "Ingredient 2"],
            instructions: ["Step 1", "Step 2"]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(recipe)
        XCTAssertNotNil(data)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decodedRecipe = try decoder.decode(Recipe.self, from: data)
        XCTAssertEqual(decodedRecipe.id, recipe.id)
        XCTAssertEqual(decodedRecipe.slug, recipe.slug)
        XCTAssertEqual(decodedRecipe.title, recipe.title)
        XCTAssertEqual(decodedRecipe.ingredients.count, 2)
        XCTAssertEqual(decodedRecipe.instructions.count, 2)
    }

    func testRecipeURLGeneration() throws {
        let recipe = Recipe(
            id: "test-1",
            slug: "chocolate-cake",
            title: "Chocolate Cake",
            thumbnailImage: "thumb.jpg",
            originalImage: "original.jpg",
            qrCodeImage: "qr.png"
        )

        XCTAssertNotNil(recipe.thumbnailURL)
        XCTAssertTrue(recipe.thumbnailURL?.absoluteString.contains("thumbnails/thumb.jpg") ?? false)

        XCTAssertNotNil(recipe.originalImageURL)
        XCTAssertTrue(recipe.originalImageURL?.absoluteString.contains("uploads/original.jpg") ?? false)

        XCTAssertNotNil(recipe.qrCodeURL)
        XCTAssertTrue(recipe.qrCodeURL?.absoluteString.contains("qr/qr.png") ?? false)

        XCTAssertTrue(recipe.recipeURL.absoluteString.contains("r/chocolate-cake"))
    }
}
