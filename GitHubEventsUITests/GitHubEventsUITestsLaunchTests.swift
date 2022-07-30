import XCTest

class GitHubEventsUITestsLaunchTests: XCTestCase {
//  override class var runsForEachTargetApplicationUIConfiguration: Bool {
//    true
//  }

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLaunch() {
    let app = XCUIApplication()
    app.launch()
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Launch Screen"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  func testFilterByLabel() {
    let app = XCUIApplication()
    app.launch()
    let firstLabel = app.staticTexts["123"].firstMatch
    firstLabel.tap()
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Filtered by label"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  func testFilterBySearch() {
    let app = XCUIApplication()
    app.launch()
    let searchBar = app.searchFields.firstMatch
    searchBar.tap()
    searchBar.typeText("Ha")
    sleep(1)
    let eventCountText = app.staticTexts["Event Count"].firstMatch
    XCTAssertEqual(eventCountText.label, "2 events")
    searchBar.typeText("g")
    XCTAssertEqual(eventCountText.label, "1 event")
    searchBar.typeText("p")
    XCTAssertEqual(eventCountText.label, "No events found for Hagp")
  }

  func testFilterBySearchAndLabel() {
    let app = XCUIApplication()
    app.launch()
    let searchBar = app.searchFields.firstMatch
    searchBar.tap()
    searchBar.typeText("Ri")
    let firstLabel = app.staticTexts["123"].firstMatch
    firstLabel.tap()
    let eventCountText = app.staticTexts["Event Count"].firstMatch
    XCTAssertEqual(eventCountText.label, "1 event")
  }
}
