//
//  Measurement.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import FirebaseFirestore
import Foundation

struct MainEmotion: Codable {
    let name: String
    let value: Float
}

struct Measurement: Identifiable, Codable {
    @DocumentID var id: String? // Populated automatically by Firestore

    let mainEmotion: MainEmotion
    let angry: Float
    let disgust: Float
    let fear: Float
    let happy: Float
    let sad: Float
    let surprised: Float
    let spontaneity: Float
    let date: Date
    let isDeleted: Bool

    /// Manual initializer used when creating a new Measurement in-app.
    init(
        id: String? = nil,
        angry: Float,
        disgust: Float,
        fear: Float,
        happy: Float,
        sad: Float,
        surprised: Float,
        spontaneity: Float,
        mainEmotion: MainEmotion,
        date: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.angry = angry
        self.disgust = disgust
        self.fear = fear
        self.happy = happy
        self.sad = sad
        self.surprised = surprised
        self.spontaneity = spontaneity
        self.mainEmotion = mainEmotion
        self.date = date
        self.isDeleted = isDeleted
    }

    var asDictionary: [String: Any] {
        [
            "angry": angry,
            "disgust": disgust,
            "fear": fear,
            "happy": happy,
            "sad": sad,
            "surprised": surprised,
            "spontaneity": spontaneity,
            "mainEmotion": [
                "name": mainEmotion.name,
                "value": mainEmotion.value
            ],
            "date": Timestamp(date: date),
            "isDeleted": isDeleted
        ]
    }
}
