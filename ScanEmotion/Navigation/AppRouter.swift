//
//  AppRouter.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 21.06.2025.
//

import SwiftUI

@Observable
class AppRouter {
    enum Screen {
        case login
        case home
    }

    var currentScreen: Screen = .login
}
