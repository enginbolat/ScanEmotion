import SwiftUI

struct ContentView: View {
    @Environment(UserSession.self) var userSession
    @Environment(AppRouter.self) var router

    var body: some View {
        switch router.currentScreen {
        case .login: NavigationStack { LoginView(appRouter: router, userSession: userSession) }
        case .home: NavigationStack { HomeView() }
        }
    }
}

#Preview {
    ContentView()
        .environment(UserSession())
        .environment(AppRouter())
}
