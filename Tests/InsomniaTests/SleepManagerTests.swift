import XCTest
import IOKit.pwr_mgt
@testable import InsomniaCore

final class MockPowerAssertionManager: PowerAssertionManaging {
    private(set) var createCallCount = 0
    private(set) var releaseCallCount = 0
    var shouldSucceed = true

    func create(type: CFString, name: CFString, id: inout IOPMAssertionID) -> IOReturn {
        createCallCount += 1
        id = 42
        return shouldSucceed ? kIOReturnSuccess : kIOReturnError
    }

    func release(id: IOPMAssertionID) {
        releaseCallCount += 1
    }
}

@MainActor
final class SleepManagerTests: XCTestCase {
    var mock: MockPowerAssertionManager!
    var sleepManager: SleepManager!

    override func setUp() {
        super.setUp()
        mock = MockPowerAssertionManager()
        sleepManager = SleepManager(assertionManager: mock)
    }

    override func tearDown() {
        sleepManager.deactivate()
        sleepManager = nil
        mock = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(sleepManager.isActive)
        XCTAssertNil(sleepManager.remainingTime)
    }

    func testToggle() {
        sleepManager.toggle()
        XCTAssertTrue(sleepManager.isActive)
        XCTAssertEqual(mock.createCallCount, 1)

        sleepManager.toggle()
        XCTAssertFalse(sleepManager.isActive)
        XCTAssertEqual(mock.releaseCallCount, 1)
    }

    func testTimerActivation() {
        let duration: TimeInterval = 60
        sleepManager.activate(for: duration)

        XCTAssertTrue(sleepManager.isActive)
        XCTAssertEqual(sleepManager.remainingTime, duration)
        XCTAssertNotNil(sleepManager.remainingTimeIdentifier)
        XCTAssertEqual(mock.createCallCount, 1)
    }

    func testConstraintToggle() {
        sleepManager.allowDisplaySleep = true
        sleepManager.activate()
        XCTAssertTrue(sleepManager.isActive)
        XCTAssertTrue(sleepManager.allowDisplaySleep)

        sleepManager.toggle()
        XCTAssertFalse(sleepManager.isActive)
    }

    func testActivateFailureDoesNotSetActive() {
        mock.shouldSucceed = false
        sleepManager.activate()
        XCTAssertFalse(sleepManager.isActive)
    }
}
