//
//  HomeViewModelTests.swift
//  ScanEmotionTests
//

import XCTest
@testable import ScanEmotion

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var mockFirebase: MockFirebaseService!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseService()
        sut = HomeViewModel(firebaseService: mockFirebase)
    }

    override func tearDown() {
        sut = nil
        mockFirebase = nil
        super.tearDown()
    }

    // MARK: - greetingText

    func test_greetingText_withEmptyUsername_returnsDefaultGreeting() {
        mockFirebase.mockCurrentUser = nil
        let vm = HomeViewModel(firebaseService: mockFirebase)
        XCTAssertEqual(vm.greetingText(), "Hoşgeldin!")
    }

    // MARK: - onItemPress

    func test_onItemPress_setsSelectedMeasurement() {
        let measurement = makeMeasurement(id: "test-1")
        sut.onItemPress(to: measurement)
        XCTAssertEqual(sut.selectedMeasurement?.id, "test-1")
    }

    func test_onItemPress_setsDetailsSheet() {
        let measurement = makeMeasurement(id: "test-1")
        sut.onItemPress(to: measurement)
        XCTAssertEqual(sut.selectedSheet, .details)
    }

    // MARK: - updateSheetType

    func test_updateSheetType_setsCorrectSheet() {
        sut.updateSheetType(key: .camera)
        XCTAssertEqual(sut.selectedSheet, .camera)
    }

    func test_updateSheetType_optionSelection_setsCorrectSheet() {
        sut.updateSheetType(key: .optionSelection)
        XCTAssertEqual(sut.selectedSheet, .optionSelection)
    }

    // MARK: - fetchDataFromFirebase

    func test_fetchData_loadsFromFirebase() async throws {
        let measurements = [makeMeasurement(id: "m1"), makeMeasurement(id: "m2")]
        mockFirebase.mockMeasurements = measurements
        mockFirebase.mockCurrentUID = "uid-123"

        let vm = HomeViewModel(firebaseService: mockFirebase)
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(vm.data.count, 2)
        XCTAssertEqual(mockFirebase.getAllMeasurementsCallCount, 1)
    }

    func test_fetchData_withNoUID_returnsEmptyData() async throws {
        mockFirebase.mockCurrentUID = nil
        let vm = HomeViewModel(firebaseService: mockFirebase)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(vm.data.isEmpty)
    }

    // MARK: - Initial state

    func test_initialData_isEmpty() {
        XCTAssertTrue(sut.data.isEmpty)
    }

    func test_initialSelectedMeasurement_isNil() {
        XCTAssertNil(sut.selectedMeasurement)
    }

    // MARK: - Helper

    private func makeMeasurement(id: String) -> Measurement {
        var m = Measurement(
            angry: 0.1, disgust: 0.1, fear: 0.1, happy: 0.5,
            sad: 0.1, surprised: 0.05, spontaneity: 0.05,
            mainEmotion: MainEmotion(name: "Mutlu", value: 0.5)
        )
        m.id = id
        return m
    }
}
