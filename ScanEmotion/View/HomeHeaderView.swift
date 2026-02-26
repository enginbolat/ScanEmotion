//
//  HomeHeaderView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct HomeHeaderView: View {
    @Environment(UserSession.self) var userSession
    @Environment(AppRouter.self) var router
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink(destination: ProfileView(appRouter: router, userSession: userSession)) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    HomeHeaderView(title: "Header")
        .environment(UserSession())
        .environment(AppRouter())
        .padding(AppConstants.padding)
}
