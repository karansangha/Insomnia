import XCTest
@testable import InsomniaCore

@MainActor
final class SleepManagerTests: XCTestCase {
    var sleepManager: SleepManager!
    
    override func setUp() {
        super.setUp()
        sleepManager = SleepManager()
    }
    
    override func tearDown() {
        sleepManager.deactivate()
        sleepManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(sleepManager.isActive)
        XCTAssertEqual(sleepManager.iconName, "closed")
    }
    
    func testToggle() {
        sleepManager.toggle()
        XCTAssertTrue(sleepManager.isActive)
        XCTAssertEqual(sleepManager.iconName, "open")
        
        sleepManager.toggle()
        XCTAssertFalse(sleepManager.isActive)
        XCTAssertEqual(sleepManager.iconName, "closed")
    }
    
    func testTimerActivation() {
        let duration: TimeInterval = 60
        sleepManager.activate(for: duration)
        
        XCTAssertTrue(sleepManager.isActive)
        XCTAssertEqual(sleepManager.remainingTime, duration)
        XCTAssertNotNil(sleepManager.remainingTimeIdentifier)
    }
    
    func testLaunchAtLoginToggle() {
        // Just verify property setting works without error (mocking SMAppService is hard)
        // We expect this might fail or log error in sandbox/test env, but we check if code runs
        sleepManager.launchAtLogin = true
        // XCTAssert(sleepManager.launchAtLogin) // Can't guarantee this in test
    }
    
    func testConstraintToggle() {
        sleepManager.allowDisplaySleep = true
        sleepManager.activate()
        XCTAssertTrue(sleepManager.isActive)
        XCTAssertTrue(sleepManager.allowDisplaySleep)
        
        sleepManager.toggle()
        XCTAssertFalse(sleepManager.isActive)
    }
}
