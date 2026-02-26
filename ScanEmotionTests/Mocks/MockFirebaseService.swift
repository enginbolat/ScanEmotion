//
//  MockFirebaseService.swift
//  ScanEmotionTests
//

import FirebaseAuth
import Foundation
@testable import ScanEmotion

final class MockFirebaseService: FirebaseServiceProtocol {
    // MARK: - Kontrol değişkenleri

    var shouldSignInSucceed = true
    var shouldSignUpSucceed = true
    var shouldUpdateProfileSucceed = true
    var mockMeasurements: [Measurement] = []
    var mockCurrentUID: String? = "mock-uid-123"
    var mockCurrentUser: User?

    // MARK: - Çağrı sayaçları

    var signInCallCount = 0
    var signUpCallCount = 0
    var addUserToFirebaseCallCount = 0
    var addMeasurementCallCount = 0
    var getAllMeasurementsCallCount = 0
    var updateUserProfileCallCount = 0
    var signOutCallCount = 0

    // MARK: - FirebaseServiceProtocol

    var currentUID: String? {
        mockCurrentUID
    }

    var currentUser: User? {
        mockCurrentUser
    }

    func signInWithGoogle() async -> FirebaseUser? {
        nil
    }

    func signOut(completion: @escaping (Result<Bool, Error>) -> Void) {
        signOutCallCount += 1
        completion(.success(true))
    }

    func checkUserSession() async -> FirebaseUser? {
        nil
    }

    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseUser, Error>) -> Void) async {
        signInCallCount += 1
        if shouldSignInSucceed {
            completion(.success(FirebaseUser(uid: mockCurrentUID, displayName: "Test User", email: email)))
        } else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Giriş başarısız."]
            )))
        }
    }

    func signUp(
        email: String,
        password: String,
        name: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) async {
        signUpCallCount += 1
        if shouldSignUpSucceed {
            completion(.success(true))
        } else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Kayıt başarısız."]
            )))
        }
    }

    func addUserToFirebase(uid: String, name: String, surname: String, email: String) async {
        addUserToFirebaseCallCount += 1
    }

    func addMeasurementToFirebase(uid: String, measurement: Measurement) async -> String {
        addMeasurementCallCount += 1
        return "mock-document-id"
    }

    func getAllMeasurements(uid: String) async -> [Measurement] {
        getAllMeasurementsCallCount += 1
        return mockMeasurements
    }

    func getMeasurementByID(uid: String, id: String) async -> Measurement? {
        nil
    }

    func updateMeasurementByID(uid: String, documentId: String, measurement: Measurement) async -> Bool {
        true
    }

    func updateUserProfile(uid: String, name: String, surname: String) async -> Bool {
        updateUserProfileCallCount += 1
        return shouldUpdateProfileSucceed
    }
}
