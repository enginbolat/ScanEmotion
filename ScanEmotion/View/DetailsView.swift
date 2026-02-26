//
//  DetailsView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import Charts
import SwiftUI

struct DetailsView: View {
    let measurement: Measurement

    private var emotionData: [(label: String, value: Float)] {
        zip(Emotion.allCases.map(\.localizedName), [
            measurement.angry,
            measurement.disgust,
            measurement.fear,
            measurement.happy,
            measurement.sad,
            measurement.surprised,
            measurement.spontaneity
        ]).map { (label: $0, value: $1) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(measurement.mainEmotion.name)
                    .font(.title2)
                    .bold()
                Text(String(format: String(localized: "%.1f%% confidence"), measurement.mainEmotion.value * 100))
                    .foregroundStyle(.secondary)
                Text(measurement.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart(emotionData, id: \.label) { item in
                BarMark(
                    x: .value("Duygu", item.label),
                    y: .value("Percentage", item.value * 100)
                )
                .foregroundStyle(
                    item.label == measurement.mainEmotion.name
                        ? Color.blue
                        : Color.blue.opacity(0.35)
                )
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...100)
            .chartYAxisLabel("%")
            .frame(height: 200)
        }
        .padding(AppConstants.padding)
    }
}

#Preview {
    DetailsView(measurement: Measurement(
        angry: 0.05,
        disgust: 0.03,
        fear: 0.07,
        happy: 0.72,
        sad: 0.04,
        surprised: 0.06,
        spontaneity: 0.03,
        mainEmotion: MainEmotion(name: "Mutlu", value: 0.72)
    ))
}
