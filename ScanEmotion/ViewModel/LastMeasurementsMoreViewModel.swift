//
//  LastMeasurementsMoreViewModel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

protocol LastMeasurementsMoreViewModelProtocol {
    var selectedMeasurement: Measurement? { get set }
    var sheetHeight: CGFloat { get set }
    func onItemPress(to measurement: Measurement)
}

@Observable
final class LastMeasurementsMoreViewModel: LastMeasurementsMoreViewModelProtocol {
    var selectedMeasurement: Measurement?
    var sheetHeight: CGFloat = .zero

    func onItemPress(to measurement: Measurement) {
        selectedMeasurement = measurement
    }
}
