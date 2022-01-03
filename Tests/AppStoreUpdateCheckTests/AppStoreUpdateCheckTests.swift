import XCTest
@testable import AppStoreUpdateCheck
    
final class AppStoreUpdateCheckTests: XCTestCase {
    
    func test_with_same_version_of_single_digit_returns_no_update() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1", with: "1")
        XCTAssertFalse(updateTuple.updateAvailable)
        XCTAssertFalse(updateTuple.haveToForceUpdate)
    }
    
    func test_with_same_version_of_double_digits_returns_no_update() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.0", with: "1.0")
        XCTAssertFalse(updateTuple.updateAvailable)
        XCTAssertFalse(updateTuple.haveToForceUpdate)
    }
    
    func test_with_same_version_of_triple_digits_returns_no_update() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.0.0", with: "1.0.0")
        XCTAssertFalse(updateTuple.updateAvailable)
        XCTAssertFalse(updateTuple.haveToForceUpdate)
    }
    
    func test_with_minor_version_change_returns_only_update_available() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.0.0", with: "1.0.1")
        XCTAssertTrue(updateTuple.updateAvailable)
        XCTAssertFalse(updateTuple.haveToForceUpdate)
    }
    
    func test_with_sub_major_version_change_returns_update_and_force_update_available() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.0.11", with: "1.1")
        XCTAssertTrue(updateTuple.updateAvailable)
        XCTAssertTrue(updateTuple.haveToForceUpdate)
    }
    
    func test_with_greater_version_than_app_store_returns_no_update() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.1", with: "1")
        XCTAssertFalse(updateTuple.updateAvailable)
        XCTAssertFalse(updateTuple.haveToForceUpdate)
    }
    
    func test_with_major_version_change_returns_update_and_force_update_available() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.1.11", with: "2")
        XCTAssertTrue(updateTuple.updateAvailable)
        XCTAssertTrue(updateTuple.haveToForceUpdate)
    }
    
    func test_with_major_version_change_returns_update_and_force_update_available1() {
        let updateChecker = AppStoreUpdateChecker()
        let updateTuple = updateChecker.checkUpdate(of: "1.0.13", with: "2")
        XCTAssertTrue(updateTuple.updateAvailable)
        XCTAssertTrue(updateTuple.haveToForceUpdate)
    }
    
}
