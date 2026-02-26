//
//  LoginView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

enum Field: Hashable {
    case email, password
}

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?
    @State private var errorMessage: String?

    init(appRouter: AppRouter, userSession: UserSession) {
        _viewModel = State(initialValue: LoginViewModel(appRouter: appRouter, userSession: userSession))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()

            Input(
                placeholder: "Email",
                LeftIcon: Image(systemName: "envelope"),
                autocapitalization: .never,
                isPasswordSecured: .constant(false),
                text: $viewModel.email
            )
            .onChange(of: viewModel.email) { viewModel.updateButtonState() }

            if let emailError = viewModel.emailError {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppConstants.padding)
            }

            Input(
                placeholder: "Password",
                LeftIcon: Image(systemName: "lock"),
                RightIcon: Image(systemName: "eye"),
                rightButtonPressed: { viewModel.isPasswordSecured.toggle() },
                isSecure: true,
                isPasswordSecured: $viewModel.isPasswordSecured,
                text: $viewModel.password
            )

            ButtonWithLabel(
                label: "Sign In",
                onPress: viewModel.signIn,
                isButtonDisabled: viewModel.isButtonDisabled
            )

            Spacer()

            NavigationLink(destination: SignUpView()) {
                HStack(spacing: 4) {
                    Text("Don't have an account?").foregroundColor(.gray)
                    Text("Sign up").foregroundColor(.blue).underline()
                }
                .font(.footnote)
            }
        }
        .padding(EdgeInsets(top: 0, leading: AppConstants.cornerRadius, bottom: 0, trailing: AppConstants.cornerRadius))
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
        .onChange(of: viewModel.state) { _, newState in
            if case let .error(message) = newState { errorMessage = message }
        }
    }
}

#Preview {
    LoginView(appRouter: AppRouter(), userSession: UserSession())
}
