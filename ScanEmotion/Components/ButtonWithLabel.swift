//
//  ButtonWithLabel.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct ButtonWithLabel: View {
    let label: String
    let onPress: () -> Void
    let isButtonDisabled: Bool

    let leftImage: Image?
    let rightImage: Image?

    init(
        label: String,
        onPress: @escaping () -> Void,
        isButtonDisabled: Bool,
        leftImage: Image? = nil,
        rightImage: Image? = nil
    ) {
        self.label = label
        self.onPress = onPress
        self.isButtonDisabled = isButtonDisabled
        self.leftImage = leftImage
        self.rightImage = rightImage
    }

    var body: some View {
        Button(action: { onPress() }) {
            HStack(spacing: 8) {
                if let LeftImage = leftImage { LeftImage }
                Text(label).fontWeight(.semibold)
                if let RightImage = rightImage { RightImage }

            }.frame(maxWidth: .infinity)
                .padding()
                .background(isButtonDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .opacity(isButtonDisabled ? 0.5 : 1.0)
                .cornerRadius(AppConstants.cornerRadius)
        }.disabled(isButtonDisabled)
    }
}

#Preview {
    ButtonWithLabel(
        label: "Sign In",
        onPress: {},
        isButtonDisabled: false,
        leftImage: Image(systemName: "camera")
    )
    .padding(AppConstants.padding)
}
