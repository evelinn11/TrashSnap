//
//  ContentView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import PhotosUI
import SwiftUI
import Vision

struct ContentView: View {

    // initialize view model
    @StateObject private var viewModel = MainViewModel()

    // navigation to result view
    @State private var showResult = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {

                // App title
                VStack(spacing: 10) {
                    Text("TrashSnap")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.brandTeal)

                    Text(
                        "Take a picture of your trash and \nfind out what type it is!"
                    )
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                }

                // Image Area
                Group {
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 224, height: 224)
                            .clipped()
                            .overlay {
                                Rectangle()
                                    .stroke(.brandTeal, lineWidth: 2)
                            }
                    } else {
                        ImagePlaceholderView()
                    }
                }

                VStack(spacing: 23) {
                    HStack(spacing: 22) {
                        // Photo source
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            ImageSourceLabel(systemImage: "photo.on.rectangle")
                        }
                        .frame(width: 101)
                        .onChange(of: viewModel.selectedPhotoItem) {
                            Task {
                                await viewModel.loadSelectedPhoto()
                            }
                        }

                        Button {
                            showCamera = true
                        } label: {
                            ImageSourceLabel(systemImage: "camera")
                        }
                        .buttonStyle(.plain)
                        .frame(width: 101)
                    }

                    // Classify Button
                    Button {
                        viewModel.classifySelectedImage()
                        if viewModel.classificationResult != nil {
                            showResult = true
                        }
                    } label: {
                        Text(
                            viewModel.isClassifying
                                ? "Classifying..." : "Classify"
                        )
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 224, minHeight: 58)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(
                        viewModel.selectedImage == nil
                            ? Color.gray.opacity(0.38) : .brandTeal
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(
                        viewModel.selectedImage == nil
                            || viewModel.isClassifying
                    )
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .padding(.horizontal, 24)
            .navigationDestination(
                isPresented: $showResult
            ) {
                if let result = viewModel.classificationResult,
                    let image = viewModel.selectedImage
                {
                    ResultView(
                        image: image,
                        result: result
                    )
                }
            }
            .fullScreenCover(
                isPresented: $showCamera
            ) {
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    CameraPicker { image in
                        viewModel.setSelectedImage(image)
                    }
                    .ignoresSafeArea()
                }
            }
        }
    }
    
    private func compareClassificationMethods(
        image: UIImage
    ) {

        do {

            print("\n========================")
            print("CLASSIFICATION COMPARISON")
            print("========================")


            // -------------------------
            // Manual baseline
            // -------------------------

            let pixelBuffer =
                try ImagePreprocessor
                    .makePixelBuffer(
                        from: image
                    )

            let manualClassifier =
                try TrashClassifierService()

            let manualResult =
                try manualClassifier.classify(
                    pixelBuffer: pixelBuffer
                )

            printResult(
                name: "Manual",
                result: manualResult
            )


            // -------------------------
            // Vision classifier
            // -------------------------

            let visionClassifier =
                try VisionTrashClassifierService()


            // Scale Fill
            let scaleFillResult =
                try visionClassifier.classify(
                    image: image,
                    cropAndScaleOption: .scaleFill
                )

            printResult(
                name: "Vision - Scale Fill",
                result: scaleFillResult
            )


            // Scale Fit
            let scaleFitResult =
                try visionClassifier.classify(
                    image: image,
                    cropAndScaleOption: .scaleFit
                )

            printResult(
                name: "Vision - Scale Fit",
                result: scaleFitResult
            )


            // Center Crop
            let centerCropResult =
                try visionClassifier.classify(
                    image: image,
                    cropAndScaleOption: .centerCrop
                )

            printResult(
                name: "Vision - Center Crop",
                result: centerCropResult
            )

        } catch {

            print(
                "Comparison failed:",
                error
            )
        }
    }
    
    private func printResult(
        name: String,
        result: ClassificationResult
    ) {

        print("\n\(name)")

        print(
            "Prediction:",
            result.topPrediction.label
        )

        print(
            "Confidence:",
            String(
                format: "%.2f%%",
                result.topPrediction.probability * 100
            )
        )
    }
}

#Preview {
    ContentView()
}
