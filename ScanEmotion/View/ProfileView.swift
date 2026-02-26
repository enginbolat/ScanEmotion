//
//  ProfileView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserSession.self) var userSession
    @State private var viewModel: ProfileViewModel
    @State private var alertMessage: String?
    @State private var showSuccessAlert = false

    init(appRouter: AppRouter, userSession: UserSession) {
        _viewModel = State(initialValue: ProfileViewModel(userSession: userSession, appRouter: appRouter))
    }

    var body: some View {
        VStack(spacing: 12) {
            ProfileInitialCharacterProfileView(
                nameFirstKey: String(viewModel.name.prefix(1)),
                surnameFirstKey: String(viewModel.surname.prefix(1)),
                photoUrl: userSession.image
            )

            VStack(alignment: .leading) {
                Text("First Name")
                Input(isPasswordSecured: .constant(false), text: $viewModel.name)
                Text("Last Name")
                Input(isPasswordSecured: .constant(false), text: $viewModel.surname)
                Text("Email")
                Input(isPasswordSecured: .constant(false), text: $viewModel.email)

                Spacer()

                VStack(spacing: 12) {
                    ButtonWithLabel(
                        label: "Save",
                        onPress: viewModel.updateProfile,
                        isButtonDisabled: viewModel.state == .loading
                    )
                    Button("Sign Out") { viewModel.signOut() }
                        .tint(Color.red)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(AppConstants.padding)
        }
        .overlay {
            if viewModel.state == .loading {
                ProgressView().scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            if let msg = alertMessage { Text(msg) }
        }
        .alert("Profile updated", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: viewModel.state) { _, newState in
            switch newState {
            case let .error(message): alertMessage = message
            case .success: showSuccessAlert = true
            default: break
            }
        }
    }
}

#Preview {
    ProfileView(appRouter: AppRouter(), userSession: UserSession())
        .environment(UserSession())
}
