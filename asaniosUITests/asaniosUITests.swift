//
//  asaniosUITests.swift
//  Spot Saver – UI tests
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import XCTest

final class asaniosUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]   // in-memory store, no location prompt
        app.launch()
    }

    @MainActor
    func testAddSpotAppearsInList() throws {
        app.tabBars.buttons["Spots"].tap()
        XCTAssertTrue(element(containing: "No Spots Yet").waitForExistence(timeout: 3))

        app.buttons["addSpotButton"].tap()

        let save = app.buttons["saveButton"]
        XCTAssertFalse(save.isEnabled, "Save must be disabled until a name is entered")

        let name = app.textFields["nameField"]
        name.tap()
        name.typeText("Test Café")
        XCTAssertTrue(save.isEnabled)
        save.tap()

        XCTAssertTrue(element(containing: "Test Café").waitForExistence(timeout: 3))
    }

    @MainActor
    func testSampleSpotsCanBeSearched() throws {
        app.tabBars.buttons["Spots"].tap()
        app.buttons["Load Sample Spots"].tap()
        XCTAssertTrue(element(containing: "SLIIT Library").waitForExistence(timeout: 3))

        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("parking")
        XCTAssertTrue(element(containing: "Free Parking Lane").waitForExistence(timeout: 2))
        XCTAssertFalse(element(containing: "SLIIT Library").exists)
    }

    @MainActor
    func testOpenDetailAndMarkVisited() throws {
        app.tabBars.buttons["Spots"].tap()
        app.buttons["Load Sample Spots"].tap()
        element(containing: "Rice & Curry Corner").tap()
        XCTAssertTrue(element(containing: "Not visited yet").waitForExistence(timeout: 2))
        app.buttons["I'm Here"].tap()
        XCTAssertTrue(element(containing: "1 visit").waitForExistence(timeout: 2))
    }

    /// Rows combine their texts for VoiceOver, so match on contained text.
    private func element(containing text: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", text))
            .firstMatch
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
