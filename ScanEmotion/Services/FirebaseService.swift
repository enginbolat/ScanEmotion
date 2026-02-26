//
//  FirebaseService.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 16.06.2025.
//

import Firebase
import FirebaseAuth
import FirebaseCrashlytics
import GoogleSignIn

enum FirestoreCollectionEnum: String {
    case users
    case user
    case userDetail = "user-detail"
    case measurements
}

protocol FirebaseServiceProtocol {
    // MARK: - Session

    var currentUID: String? { get }
    var currentUser: User? { get }

    // MARK: - Auth

    func signInWithGoogle() async -> FirebaseUser?
    func signOut(completion: @escaping (Result<Bool, Error>) -> Void)
    func checkUserSession() async -> FirebaseUser?

    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseUser, Error>) -> Void) async
    func signUp(
        email: String,
        password: String,
        name: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) async
    func addUserToFirebase(uid: String, name: String, surname: String, email: String) async

    // MARK: - Firestore

    func addMeasurementToFirebase(uid: String, measurement: Measurement) async -> String
    func getAllMeasurements(uid: String) async -> [Measurement]
    func getMeasurementByID(uid: String, id: String) async -> Measurement?
    func updateMeasurementByID(uid: String, documentId: String, measurement: Measurement) async -> Bool
    func updateUserProfile(uid: String, name: String, surname: String) async -> Bool
}

public class FirebaseService: FirebaseServiceProtocol {
    static let shared = FirebaseService()

    private let firestoreDb: Firestore
    private var isConfigReady: Bool = false

    init(firestoreDb: Firestore = Firestore.firestore()) {
        self.firestoreDb = firestoreDb
    }

    // MARK: - SIGN IN

    func signInWithGoogle() async -> FirebaseUser? {
        do {
            // 1. Fetch root view controller on the main thread
            let rootViewController = await getRootViewController()

            guard let presentingVC = rootViewController else {
                log("No root view controller", isError: true)
                return nil
            }

            // 2. Fetch client ID
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                log("Missing Firebase client ID", isError: true)
                return nil
            }

            // 3. Configure Google Sign-In
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            // 4. Start Google Sign-In
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)

            // 5. Build credential and sign in to Firebase
            let user = signInResult.user
            guard let idToken = user.idToken?.tokenString else {
                log("Missing idToken", isError: true)
                return nil
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            let authResult = try await Auth.auth().signIn(with: credential)
            log("Firebase Sign-In successful: \(authResult.user.email ?? "no email")", isError: false)

            return FirebaseUser(user: authResult.user)

        } catch {
            log("SignInWithGoogle Error: \(error.localizedDescription)", isError: true)
            return nil
        }
    }

    func signOut(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            log("Successfully signed out", isError: false)
            completion(.success(true))
        } catch {
            log("Sign out failed: \(error.localizedDescription)", isError: true)
            completion(.failure(error))
        }
    }

    func checkUserSession() async -> FirebaseUser? {
        let currentUser = Auth.auth().currentUser
        if let currentUser {
            return FirebaseUser(user: currentUser)
        } else {
            return nil
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseUser, Error>) -> Void) async {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                completion(.success(FirebaseUser(user: user)))
            } else {
                completion(.failure(AppError.userNotFound))
            }
        }
    }

    func signUp(
        email: String,
        password: String,
        name: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) async {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                log("Failed to create user: \(error.localizedDescription)", isError: true)
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(AppError.signUpFailed))
                return
            }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error {
                    log("Failed to save display name: \(error.localizedDescription)", isError: true)
                    completion(.failure(error))
                    return
                }

                log("User created and displayName set.", isError: false)
                completion(.success(true))
            }
        }
    }

    func addUserToFirebase(uid: String, name: String, surname: String, email: String) async {
        await withCheckedContinuation { continuation in
            let dictionary: [String: Any] = [
                "name": name,
                "surname": surname,
                "email": email
            ]

            firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.user.rawValue)
                .addDocument(data: dictionary) { error in
                    if let error {
                        log("Failed to add user: \(error.localizedDescription)", isError: true)
                    } else {
                        log("User added successfully", isError: false)
                    }
                    continuation.resume()
                }
        }
    }

    func addMeasurementToFirebase(uid: String, measurement: Measurement) async -> String {
        await withCheckedContinuation { continuation in
            var ref: DocumentReference?
            ref = firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.measurements.rawValue)
                .addDocument(data: measurement.asDictionary) { error in
                    if let error {
                        log("Failed to add measurement: \(error.localizedDescription)", isError: true)
                        continuation.resume(returning: "")
                    } else {
                        let documentId = ref?.documentID ?? ""
                        log("Measurement added successfully, ID: \(documentId)", isError: false)
                        continuation.resume(returning: documentId)
                    }
                }
        }
    }

    func getAllMeasurements(uid: String) async -> [Measurement] {
        do {
            let snapshot = try await firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.measurements.rawValue)
                .getDocuments()

            return snapshot.documents.compactMap { document -> Measurement? in
                do {
                    return try document.data(as: Measurement.self)
                } catch {
                    log(error.localizedDescription, isError: true)
                    return nil
                }
            }
        } catch {
            log(error.localizedDescription, isError: true)
            return []
        }
    }

    func getMeasurementByID(uid: String, id: String) async -> Measurement? {
        do {
            let documentSnapshot = try await firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.measurements.rawValue)
                .document(id)
                .getDocument()

            return try? documentSnapshot.data(as: Measurement.self)
        } catch {
            log(error.localizedDescription, isError: true)
            return nil
        }
    }

    func updateMeasurementByID(uid: String, documentId: String, measurement: Measurement) async -> Bool {
        do {
            try await firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.measurements.rawValue)
                .document(documentId)
                .updateData(["isDeleted": measurement.isDeleted])
            return true
        } catch {
            log(error.localizedDescription, isError: true)
            return false
        }
    }

    func updateUserProfile(uid: String, name: String, surname: String) async -> Bool {
        do {
            let snapshot = try await firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.user.rawValue)
                .getDocuments()

            guard let document = snapshot.documents.first else { return false }

            try await firestoreDb
                .collection(FirestoreCollectionEnum.users.rawValue)
                .document(uid)
                .collection(FirestoreCollectionEnum.user.rawValue)
                .document(document.documentID)
                .updateData(["name": name, "surname": surname])

            log("Profile updated successfully", isError: false)
            return true
        } catch {
            log("Failed to update profile: \(error.localizedDescription)", isError: true)
            return false
        }
    }
}

private func log(_ message: String, isError: Bool = false) {
    #if DEBUG
        print(isError ? "❌" : "✅", message)
    #else
        Crashlytics.crashlytics().log(message)
    #endif
}

extension FirebaseService {
    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    var currentUser: User? {
        Auth.auth().currentUser
    }
}
