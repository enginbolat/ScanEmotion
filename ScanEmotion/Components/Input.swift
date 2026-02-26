//
//  Input.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct Input: View {
    var placeholder: LocalizedStringKey = "Placeholder"

    var LeftIcon: Image?
    var leftButtonPressed: (() -> Void)?

    var RightIcon: Image?
    var rightButtonPressed: (() -> Void)?

    var autocapitalization: TextInputAutocapitalization?
    var isSecure: Bool = false
    @Binding var isPasswordSecured: Bool
    @Binding var text: String

    var body: some View {
        HStack {
            if let LeftIcon {
                PressableIcon(icon: LeftIcon, onPress: leftButtonPressed, isDisabled: leftButtonPressed == nil)
            }

            Group {
                if isSecure, isPasswordSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(autocapitalization)
                }
            }
            .frame(height: 20)
            .textFieldStyle(.plain)

            if let RightIcon {
                PressableIcon(icon: RightIcon, onPress: rightButtonPressed, isDisabled: rightButtonPressed == nil)
            }
        }.padding()
            .glassBackground()
    }
}

#Preview {
    Input(
        placeholder: "Preview",
        LeftIcon: Image(systemName: "lock"),
        leftButtonPressed: {},
        RightIcon: Image(systemName: "eye"),
        rightButtonPressed: {},
        isSecure: true,
        isPasswordSecured: .constant(true),
        text: .constant("Password")
    ).padding(AppConstants.padding)
}
