//
//  GlassBackgroundModifier.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

// MARK: - Modifier

struct GlassBackgroundModifier: ViewModifier {
    let shape: AnyShape

    init(shape: some InsettableShape) {
        self.shape = AnyShape(shape)
    }

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
        }
    }
}

// MARK: - View Extension

extension View {
    /// iOS 26'da Liquid Glass, iOS 17-25'te ultraThinMaterial uygular.
    func glassBackground(in shape: some InsettableShape = RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
        -> some View
    {
        modifier(GlassBackgroundModifier(shape: shape))
    }
}
