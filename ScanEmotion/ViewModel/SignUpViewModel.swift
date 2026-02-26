//
//  SignUpViewModel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

protocol SignUpViewModelProtocol {
    var name: String { get set }
    var surname: String { get set }
    var email: String { get set }
    var password: String { get set }
    var isPasswordSecured: Bool { get set }
    var signUpSucceeded: Bool { get set }
    var state: ViewState { get }

    func onSignUp()
    func isButtonDisabled() -> Bool
    func performSignUp() async -> Bool
}

@Observable
final class SignUpViewModel: SignUpViewModelProtocol {
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var emailError: String?
    var password: String = ""
    var passwordConfirmation: String = ""
    var isPasswordSecured: Bool = true
    var isPasswordConfirmationSecured: Bool = true
    var signUpSucceeded: Bool = false
    var state: ViewState = .idle

    private let firebaseService: FirebaseServiceProtocol
    private let storageService: AppStorageServiceProtocol

    init(
        firebaseService: FirebaseServiceProtocol = FirebaseService.shared,
        storageService: AppStorageServiceProtocol = AppStorageService.shared
    ) {
        self.firebaseService = firebaseService
        self.storageService = storageService
    }

    func onSignUp() {
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            let success = await performSignUp()
            await MainActor.run {
                if success {
                    self.state = .idle
                    self.signUpSucceeded = true
                }
            }
        }
    }

    func performSignUp() async -> Bool {
        let displayName = "\(name) \(surname)"
        var result = false
        var signUpError: Error?

        await firebaseService.signUp(email: email, password: password, name: displayName) { [weak self] outcome in
            guard let self else { return }
            switch outcome {
            case let .success(status):
                if status {
                    guard let uid = firebaseService.currentUID else { return }
                    addUserToFirebase(uid)
                    result = true
                }
            case let .failure(error):
                signUpError = error
            }
        }

        if let error = signUpError {
            await MainActor.run { self.state = .error(error.localizedDescription) }
        }

        return result
    }

    private func addUserToFirebase(_ uid: String) {
        Task { [weak self] in
            guard let self else { return }
            await firebaseService.addUserToFirebase(
                uid: uid,
                name: name,
                surname: surname,
                email: email
            )
        }

        storageService.set(name, forKey: .name)
        storageService.set(surname, forKey: .surname)
        storageService.set(email, forKey: .email)
        storageService.set(true, forKey: .isLoggedIn)
    }

    func isValidEmail() -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
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

    func isButtonDisabled() -> Bool {
        name.isEmpty || surname.isEmpty || email.isEmpty || !isValidEmail()
            || password.isEmpty || password.count < 6
            || passwordConfirmation.isEmpty || password != passwordConfirmation
    }
}
