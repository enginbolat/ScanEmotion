//
//  Helper.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 16.06.2025.
//

import UIKit

@MainActor
func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first?.rootViewController
    else {
        return nil
    }
    return root
}
