//
//  SignUpViewModelTests.swift
//  ScanEmotionTests
//

import XCTest
@testable import ScanEmotion

@MainActor
final class SignUpViewModelTests: XCTestCase {
    private var mockFirebase: MockFirebaseService!
    private var mockStorage: MockAppStorageService!
    private var sut: SignUpViewModel!

    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseService()
        mockStorage = MockAppStorageService()
        sut = SignUpViewModel(firebaseService: mockFirebase, storageService: mockStorage)
    }

    override func tearDown() {
        sut = nil
        mockFirebase = nil
        mockStorage = nil
        super.tearDown()
    }

    // MARK: - isButtonDisabled

    func test_isButtonDisabled_withAllEmpty_returnsTrue() {
        XCTAssertTrue(sut.isButtonDisabled())
    }

    func test_isButtonDisabled_withMissingName_returnsTrue() {
        sut.name = ""
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        sut.passwordConfirmation = "123456"
        XCTAssertTrue(sut.isButtonDisabled())
    }

    func test_isButtonDisabled_withAllFilled_returnsFalse() {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        sut.passwordConfirmation = "123456"
        XCTAssertFalse(sut.isButtonDisabled())
    }

    func test_isButtonDisabled_withMismatchedPasswords_returnsTrue() {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        sut.passwordConfirmation = "654321"
        XCTAssertTrue(sut.isButtonDisabled())
    }

    // MARK: - performSignUp

    func test_performSignUp_onSuccess_returnsTrue() async {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        mockFirebase.shouldSignUpSucceed = true

        let result = await sut.performSignUp()

        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.signUpCallCount, 1)
    }

    func test_performSignUp_onFailure_returnsFalse() async {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        mockFirebase.shouldSignUpSucceed = false

        let result = await sut.performSignUp()

        XCTAssertFalse(result)
    }

    // MARK: - onSignUp navigation

    func test_onSignUp_onSuccess_setsSignUpSucceeded() async throws {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        mockFirebase.shouldSignUpSucceed = true

        sut.onSignUp()

        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.signUpSucceeded)
    }

    func test_onSignUp_onFailure_doesNotSetSignUpSucceeded() async throws {
        sut.name = "Ad"
        sut.surname = "Soyad"
        sut.email = "test@example.com"
        sut.password = "123456"
        mockFirebase.shouldSignUpSucceed = false

        sut.onSignUp()

        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.signUpSucceeded)
    }

    // MARK: - Initial state

    func test_initialSignUpSucceeded_isFalse() {
        XCTAssertFalse(sut.signUpSucceeded)
    }

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
    }
}
