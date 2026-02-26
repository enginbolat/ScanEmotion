//
//  LoginViewModelTests.swift
//  ScanEmotionTests
//

import XCTest
@testable import ScanEmotion

@MainActor
final class LoginViewModelTests: XCTestCase {
    private var appRouter: AppRouter!
    private var userSession: UserSession!
    private var mockFirebase: MockFirebaseService!
    private var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        appRouter = AppRouter()
        userSession = UserSession()
        mockFirebase = MockFirebaseService()
        sut = LoginViewModel(appRouter: appRouter, userSession: userSession, firebaseService: mockFirebase)
    }

    override func tearDown() {
        sut = nil
        mockFirebase = nil
        userSession = nil
        appRouter = nil
        super.tearDown()
    }

    // MARK: - isValidEmail

    func test_isValidEmail_withValidComEmail_returnsTrue() {
        sut.email = "test@example.com"
        XCTAssertTrue(sut.isValidEmail())
    }

    func test_isValidEmail_withValidNetEmail_returnsTrue() {
        sut.email = "test@example.net"
        XCTAssertTrue(sut.isValidEmail())
    }

    func test_isValidEmail_withValidOrgEmail_returnsTrue() {
        sut.email = "user@domain.org"
        XCTAssertTrue(sut.isValidEmail())
    }

    func test_isValidEmail_withMissingAt_returnsFalse() {
        sut.email = "invalidemail.com"
        XCTAssertFalse(sut.isValidEmail())
    }

    func test_isValidEmail_withEmptyString_returnsFalse() {
        sut.email = ""
        XCTAssertFalse(sut.isValidEmail())
    }

    func test_isValidEmail_withMissingDomain_returnsFalse() {
        sut.email = "test@"
        XCTAssertFalse(sut.isValidEmail())
    }

    // MARK: - updateButtonState

    func test_updateButtonState_withEmptyEmail_disablesButton() {
        sut.email = ""
        sut.password = "password123"
        sut.updateButtonState()
        XCTAssertTrue(sut.isButtonDisabled)
    }

    func test_updateButtonState_withEmptyPassword_disablesButton() {
        sut.email = "test@example.com"
        sut.password = ""
        sut.updateButtonState()
        XCTAssertTrue(sut.isButtonDisabled)
    }

    func test_updateButtonState_withValidInputs_enablesButton() {
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.updateButtonState()
        XCTAssertFalse(sut.isButtonDisabled)
    }

    func test_updateButtonState_withInvalidEmail_disablesButton() {
        sut.email = "notanemail"
        sut.password = "password123"
        sut.updateButtonState()
        XCTAssertTrue(sut.isButtonDisabled)
    }

    // MARK: - validateEmail

    func test_validateEmail_withValidEmail_clearsError() {
        sut.email = "test@example.com"
        let result = sut.validateEmail()
        XCTAssertTrue(result)
        XCTAssertNil(sut.emailError)
    }

    func test_validateEmail_withInvalidEmail_setsError() {
        sut.email = "bad-email"
        let result = sut.validateEmail()
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.emailError)
    }

    // MARK: - signIn

    func test_signIn_withInvalidEmail_doesNotCallFirebase() {
        sut.email = "invalid"
        sut.password = "password"
        sut.signIn()
        XCTAssertEqual(mockFirebase.signInCallCount, 0)
    }

    func test_signIn_withValidEmail_setsLoadingState() {
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.signIn()
        XCTAssertEqual(sut.state, .loading)
    }

    // MARK: - Initial state

    func test_initialEmail_isEmpty() {
        XCTAssertEqual(sut.email, "")
    }

    func test_initialPassword_isEmpty() {
        XCTAssertEqual(sut.password, "")
    }
}
