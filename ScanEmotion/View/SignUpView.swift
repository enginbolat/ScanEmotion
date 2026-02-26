//
//  SignUpView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AppRouter.self) var appRouter
    @State private var viewModel = SignUpViewModel()
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            Input(
                placeholder: "First Name",
                LeftIcon: Image(systemName: "person"),
                isPasswordSecured: .constant(false),
                text: $viewModel.name
            )
            Input(
                placeholder: "Last Name",
                LeftIcon: Image(systemName: "person"),
                isPasswordSecured: .constant(false),
                text: $viewModel.surname
            )
            VStack(alignment: .leading, spacing: 4) {
                Input(
                    placeholder: "Email",
                    LeftIcon: Image(systemName: "envelope"),
                    autocapitalization: .never,
                    isPasswordSecured: .constant(false),
                    text: $viewModel.email
                )
                .onChange(of: viewModel.email) { _ = viewModel.validateEmail() }

                if let emailError = viewModel.emailError {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, AppConstants.padding)
                }
            }
            Input(
                placeholder: "Password (min. 6 characters)",
                LeftIcon: Image(systemName: "lock"),
                RightIcon: Image(systemName: "eye"),
                rightButtonPressed: { viewModel.isPasswordSecured.toggle() },
                isSecure: true,
                isPasswordSecured: $viewModel.isPasswordSecured,
                text: $viewModel.password
            )
            Input(
                placeholder: "Confirm Password",
                LeftIcon: Image(systemName: "lock.fill"),
                RightIcon: Image(systemName: "eye"),
                rightButtonPressed: { viewModel.isPasswordConfirmationSecured.toggle() },
                isSecure: true,
                isPasswordSecured: $viewModel.isPasswordConfirmationSecured,
                text: $viewModel.passwordConfirmation
            )

            if !viewModel.password.isEmpty, !viewModel.passwordConfirmation.isEmpty,
               viewModel.password != viewModel.passwordConfirmation
            {
                Text("Passwords don't match")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppConstants.padding)
            }

            ButtonWithLabel(
                label: "Sign Up",
                onPress: viewModel.onSignUp,
                isButtonDisabled: viewModel.isButtonDisabled()
            )
        }
        .padding(AppConstants.padding)
        .overlay {
            if viewModel.state == .loading {
                ProgressView().scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            if let msg = errorMessage { Text(msg) }
        }
        .onChange(of: viewModel.signUpSucceeded) { _, success in
            if success { appRouter.currentScreen = .home }
        }
        .onChange(of: viewModel.state) { _, newState in
            if case let .error(message) = newState { errorMessage = message }
        }
    }
}

#Preview {
    SignUpView().environment(AppRouter())
}
