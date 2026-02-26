//
//  HomeViewModel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

enum SheetType: Identifiable, Hashable {
    case optionSelection, camera, gallery, details
    var id: Self {
        self
    }
}

protocol HomeViewModelProtocol {
    var username: String { get set }
    var data: [Measurement] { get set }
    var sheetHeight: CGFloat { get set }
    var selectedSheet: SheetType? { get set }

    func greetingText() -> String
    func classifyImage(_ uiImage: UIImage) async
}

@Observable
final class HomeViewModel: HomeViewModelProtocol {
    var username: String

    var data: [Measurement] = []
    var sheetHeight: CGFloat = .zero

    var selectedSheet: SheetType?
    var selectedMeasurement: Measurement?

    var image: UIImage?
    var state: ViewState = .idle

    private let firebaseService: FirebaseServiceProtocol
    private var classifyTask: Task<Void, Never>?

    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
        username = firebaseService.currentUser?.displayName ?? ""
        fetchDataFromFirebase()
    }

    private func fetchDataFromFirebase() {
        state = .loading
        Task { [weak self] in
            guard let self else { return }

            let measurements: [Measurement] = if let uid = firebaseService.currentUID {
                await firebaseService.getAllMeasurements(uid: uid)
            } else {
                []
            }

            await MainActor.run {
                self.data = measurements
                self.state = .idle
            }
        }
    }

    func greetingText() -> String {
        if username.isEmpty { return String(localized: "Welcome!") }
        return String(format: String(localized: "Welcome, %@!"), username)
    }

    func updateSheetType(key sheetType: SheetType) {
        selectedSheet = sheetType
    }

    func onItemPress(to measurement: Measurement) {
        selectedMeasurement = measurement
        selectedSheet = .details
    }

    func addMeasurementToFirestore(_ measurement: Measurement) async -> String {
        let currentUserSession = await firebaseService.checkUserSession()
        guard let currentUser = currentUserSession, let uid = currentUser.uid else { return "" }
        return await firebaseService.addMeasurementToFirebase(uid: uid, measurement: measurement)
    }

    func classifyImageSync(_ uiImage: UIImage) {
        classifyTask?.cancel()
        classifyTask = Task { [weak self] in
            guard let self else { return }
            await classifyImage(uiImage)
        }
    }

    @MainActor
    private func setAndUploadMeasurement(probabilities: [Float], labels: [String]) {
        Task { [weak self] in
            guard let self else { return }

            guard probabilities.count >= Emotion.allCases.count else {
                state = .error(String(localized: "Emotion analysis failed: insufficient data."))
                return
            }

            guard let maxIndex = probabilities.firstIndex(of: probabilities.max() ?? 0.0) else {
                state = .error(String(localized: "Could not detect dominant emotion."))
                return
            }

            var newElement = Measurement(
                angry: probabilities[Emotion.angry.rawValue],
                disgust: probabilities[Emotion.disgust.rawValue],
                fear: probabilities[Emotion.fear.rawValue],
                happy: probabilities[Emotion.happy.rawValue],
                sad: probabilities[Emotion.sad.rawValue],
                surprised: probabilities[Emotion.surprised.rawValue],
                spontaneity: probabilities[Emotion.spontaneity.rawValue],
                mainEmotion: MainEmotion(name: labels[maxIndex], value: probabilities[maxIndex])
            )
            let documentId = await addMeasurementToFirestore(newElement)
            newElement.id = documentId
            data.append(newElement)
        }
    }

    @MainActor
    func classifyImage(_ uiImage: UIImage) async {
        guard !Task.isCancelled else { return }
        state = .loading
        guard let inputArray = imageToMultiArray(image: uiImage) else {
            state = .error(String(localized: "Failed to process image."))
            return
        }

        do {
            let model = try EmotionModel()
            let prediction = try model.prediction(inputs: inputArray)
            let raw = prediction.Identity
            let logits = (0..<raw.count).map { raw[$0].floatValue }
            let expValues = logits.map { exp($0) }
            let sumExp = expValues.reduce(0, +)
            let probabilities = expValues.map { $0 / sumExp }

            guard probabilities.count == Emotion.allCases.count else {
                state = .error(String(localized: "Unexpected model output format."))
                return
            }

            state = .idle
            setAndUploadMeasurement(
                probabilities: probabilities,
                labels: Emotion.allCases.map(\.localizedName)
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
