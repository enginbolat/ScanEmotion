//
//  ProfileInitialCharacterProfileView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct ProfileInitialCharacterProfileView: View {
    let nameFirstKey: String
    let surnameFirstKey: String
    let photoUrl: String?

    var body: some View {
        VStack {
            if photoUrl?.isEmpty ?? true {
                HStack(spacing: 0) {
                    Text(nameFirstKey)
                        .font(.largeTitle)
                        .bold()
                    Text(surnameFirstKey)
                        .font(.largeTitle)
                        .bold()
                }
            } else {
                if let urlString = photoUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .padding(24)
        .glassBackground(in: RoundedRectangle(cornerRadius: .infinity))
    }
}

#Preview {
    ProfileInitialCharacterProfileView(nameFirstKey: "E", surnameFirstKey: "B", photoUrl: "")
}
