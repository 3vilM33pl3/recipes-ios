import XCTest

final class RecipeListUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Cleanup
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testRecipeListNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Recipes"].exists)

        // Verify toolbar buttons
        XCTAssertTrue(app.buttons["Upload"].exists)
        XCTAssertTrue(app.buttons["Filter"].exists)
    }

    func testSearchFunctionality() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists)

        searchField.tap()
        searchField.typeText("chocolate")

        // Search should filter results
        // Note: This assumes recipes are loaded
    }

    func testUploadSheet() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap upload button
        app.buttons["Upload"].tap()

        // Verify upload sheet appears
        XCTAssertTrue(app.navigationBars["Upload Recipe"].waitForExistence(timeout: 2))

        // Verify buttons exist
        XCTAssertTrue(app.buttons["Take Photo"].exists)
        XCTAssertTrue(app.buttons["Choose from Library"].exists)

        // Dismiss sheet
        app.buttons["Cancel"].tap()
    }

    func testFilterSheet() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap filter button
        app.buttons["Filter"].tap()

        // Verify filter sheet
        XCTAssertTrue(app.navigationBars["Filter & Sort"].waitForExistence(timeout: 2))

        // Verify filter options
        XCTAssertTrue(app.buttons["Sort Order"].exists)
        XCTAssertTrue(app.buttons["Difficulty"].exists)

        // Dismiss sheet
        app.buttons["Cancel"].tap()
    }

    func testPullToRefresh() throws {
        let app = XCUIApplication()
        app.launch()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)

        // Pull to refresh
        let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0, thenDragTo: end)

        // Should show loading indicator briefly
    }
}
