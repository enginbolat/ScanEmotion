//
//  Emotion.swift
//  ScanEmotion
//

import Foundation

enum Emotion: Int, CaseIterable {
    case angry = 0
    case disgust = 1
    case fear = 2
    case happy = 3
    case sad = 4
    case surprised = 5
    case spontaneity = 6

    var localizedName: String {
        switch self {
        case .angry: String(localized: "Angry")
        case .disgust: String(localized: "Disgust")
        case .fear: String(localized: "Fear")
        case .happy: String(localized: "Happy")
        case .sad: String(localized: "Sad")
        case .surprised: String(localized: "Surprised")
        case .spontaneity: String(localized: "Neutral")
        }
    }
}
