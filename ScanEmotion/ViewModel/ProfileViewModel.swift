//
//  ProfileViewModel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

protocol ProfileViewModelProtocol {
    var name: String { get set }
    var surname: String { get set }
    var email: String { get set }
    func signOut()
    func updateProfile()
}

@Observable
final class ProfileViewModel: ProfileViewModelProtocol {
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var state: ViewState = .idle

    private let userSession: UserSession
    private let appRouter: AppRouter
    private let firebaseService: FirebaseServiceProtocol
    private let storageService: AppStorageServiceProtocol

    init(
        userSession: UserSession,
        appRouter: AppRouter,
        firebaseService: FirebaseServiceProtocol = FirebaseService.shared,
        storageService: AppStorageServiceProtocol = AppStorageService.shared
    ) {
        self.userSession = userSession
        self.appRouter = appRouter
        self.firebaseService = firebaseService
        self.storageService = storageService
        setupInputs()
    }

    private func setupInputs() {
        name = userSession.name
        surname = userSession.surname
        email = userSession.email
    }

    func updateProfile() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedSurname = surname.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedSurname.isEmpty else {
            state = .error(String(localized: "Name and surname cannot be empty."))
            return
        }
        guard trimmedName.count <= 50, trimmedSurname.count <= 50 else {
            state = .error(String(localized: "Name and surname can be at most 50 characters."))
            return
        }
        guard let uid = firebaseService.currentUID else { return }
        state = .loading
        Task { [weak self] in
            guard let self else { return }
            let success = await firebaseService.updateUserProfile(uid: uid, name: trimmedName, surname: trimmedSurname)
            await MainActor.run {
                if success {
                    self.storageService.set(trimmedName, forKey: .name)
                    self.storageService.set(trimmedSurname, forKey: .surname)
                    self.userSession.name = trimmedName
                    self.userSession.surname = trimmedSurname
                    self.state = .success
                } else {
                    self.state = .error(String(localized: "Failed to update profile."))
                }
            }
        }
    }

    func signOut() {
        state = .loading
        firebaseService.signOut { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                storageService.resetAll()
                userSession.logout()
                appRouter.currentScreen = .login
            case let .failure(error):
                state = .error(error.localizedDescription)
            }
        }
    }
}
