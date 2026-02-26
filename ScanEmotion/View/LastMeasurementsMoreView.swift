//
//  LastMeasurementsMoreView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct LastMeasurementsMoreView: View {
    @State private var viewModel = LastMeasurementsMoreViewModel()
    let measurement: [Measurement]

    init(measurement: [Measurement]) {
        self.measurement = measurement
    }

    var body: some View {
        ScrollView {
            ForEach(measurement) { item in
                MeasurementCard(item: item, onItemPress: viewModel.onItemPress)
            }
        }
        .padding(20)
        .sheet(item: $viewModel.selectedMeasurement) { item in
            DetailsView(measurement: item)
                .modifier(GetHeightModifier(height: $viewModel.sheetHeight))
                .presentationDetents([.height(viewModel.sheetHeight)])
        }
    }
}

#Preview {
    LastMeasurementsMoreView(measurement: [
        Measurement(
            angry: 0.05, disgust: 0.03, fear: 0.07,
            happy: 0.72, sad: 0.04, surprised: 0.06, spontaneity: 0.03,
            mainEmotion: MainEmotion(name: "Mutlu", value: 0.72)
        )
    ])
}
