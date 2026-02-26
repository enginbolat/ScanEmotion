//
//  ScanEmotionApp.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 14.06.2025.
//

import FirebaseCore
import SwiftUI

@main
struct ScanEmotionApp: App {
    @State private var appRouter = AppRouter()
    @State private var userSession = UserSession()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appRouter)
                .environment(userSession)
        }
    }
}
