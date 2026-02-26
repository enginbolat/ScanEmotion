//
//  LoginViewModel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

protocol LoginViewModelProtocol {
    var password: String { get set }
    var isPasswordSecured: Bool { get set }
    var emailError: String? { get set }
    var state: ViewState { get }
    func isValidEmail() -> Bool
    func validateEmail() -> Bool
    func signIn()
    func updateButtonState()
}

@Observable
final class LoginViewModel: LoginViewModelProtocol {
    var email = ""
    var password = ""
    var isPasswordSecured: Bool = true
    var emailError: String?
    var isButtonDisabled: Bool = true
    var state: ViewState = .idle

    private let appRouter: AppRouter
    private let userSession: UserSession
    private let firebaseService: FirebaseServiceProtocol

    init(
        appRouter: AppRouter,
        userSession: UserSession,
        firebaseService: FirebaseServiceProtocol = FirebaseService.shared
    ) {
        self.appRouter = appRouter
        self.userSession = userSession
        self.firebaseService = firebaseService
    }

    func isValidEmail() -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with: email)
    }

    func validateEmail() -> Bool {
        if isValidEmail() {
            emailError = nil
            return true
        } else {
            emailError = String(localized: "Please enter a valid email address")
            return false
        }
    }

    func signIn() {
        guard validateEmail() else { return }
        signInRegularAsync()
    }

    func updateButtonState() {
        isButtonDisabled = email.isEmpty || password.isEmpty || !isValidEmail()
    }

    private func signInRegularAsync() {
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            await firebaseService.signIn(email: email, password: password) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(firebaseUser):
                    userSession.login(
                        name: firebaseUser.displayName ?? "",
                        surname: "",
                        email: firebaseUser.email ?? "",
                        image: firebaseUser.photoURL?.absoluteString ?? ""
                    )
                    state = .idle
                    appRouter.currentScreen = .home
                case let .failure(error):
                    state = .error(error.localizedDescription)
                    emailError = error.localizedDescription
                }
            }
        }
    }
}
