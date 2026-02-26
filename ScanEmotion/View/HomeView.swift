//
//  HomeView.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 15.06.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            HomeHeaderView(title: viewModel.greetingText())
            HomeMeasurementSectionView(
                data: viewModel.data,
                onItemPress: viewModel.onItemPress
            )
            ButtonWithLabel(
                label: "Start Scan",
                onPress: { viewModel.updateSheetType(key: .optionSelection) },
                isButtonDisabled: false,
                leftImage: Image(systemName: "camera")
            )
        }
        .padding(AppConstants.padding)
        .overlay {
            if viewModel.state == .loading {
                ProgressView().scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .sheet(item: $viewModel.selectedSheet) { item in
            switch item {
            case .optionSelection:
                HomeOptionsSheetBody(
                    photoOnPress: { viewModel.updateSheetType(key: .camera) },
                    galleryOnPress: { viewModel.updateSheetType(key: .gallery) }
                )
                .modifier(GetHeightModifier(height: $viewModel.sheetHeight))
                .presentationDetents([.height(viewModel.sheetHeight)])
            case .camera:
                ImagePicker(
                    image: $viewModel.image,
                    sourceType: .camera,
                    onImagePicked: viewModel.classifyImageSync
                ).ignoresSafeArea()
            case .gallery:
                ImagePicker(
                    image: $viewModel.image,
                    sourceType: .photoLibrary,
                    onImagePicked: viewModel.classifyImageSync
                ).ignoresSafeArea()
            case .details:
                if let measurement = viewModel.selectedMeasurement {
                    DetailsView(measurement: measurement)
                        .modifier(GetHeightModifier(height: $viewModel.sheetHeight))
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.height(viewModel.sheetHeight)])
                        .padding(.top, AppConstants.padding)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            if let msg = errorMessage { Text(msg) }
        }
        .onChange(of: viewModel.state) { _, newState in
            if case let .error(message) = newState { errorMessage = message }
        }
    }
}

#Preview {
    HomeView()
        .environment(UserSession())
        .environment(AppRouter())
}
