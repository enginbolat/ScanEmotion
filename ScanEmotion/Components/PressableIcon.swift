//
//  PressableIcon.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct PressableIcon: View {
    var icon: Image
    var onPress: (() -> Void)?
    var isDisabled: Bool = false

    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            onPress?()
        }) {
            icon
                .foregroundColor(.gray)
                .frame(width: 24)
        }
        .disabled(isDisabled)
        .accessibilityLabel("Icon button")
    }
}

#Preview {
    PressableIcon(icon: Image(systemName: "person"))
}
