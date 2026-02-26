//
//  ViewState.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
