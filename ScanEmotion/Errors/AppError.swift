//
//  AppError.swift
//  ScanEmotion
//

import Foundation

enum AppError: LocalizedError {
    case userNotFound
    case signInFailed
    case signUpFailed
    case profileNotFound
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound: String(localized: "User not found.")
        case .signInFailed: String(localized: "Sign in failed. Incorrect email or password.")
        case .signUpFailed: String(localized: "Registration failed.")
        case .profileNotFound: String(localized: "Profile information not found.")
        case let .unknown(msg): msg
        }
    }
}
