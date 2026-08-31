//
//  ContentView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @State private var showCamera = false
    
    // initialize view model
    @StateObject private var viewModel = MainViewModel()
    
    // navigation to result view
    @State private var showResult = false
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 40){
                
                Button("Open Camera") {
                    showCamera = true
                }
                .fullScreenCover(
                    isPresented: $showCamera
                ) {

                    CameraView()
                }
                
                // App title
                VStack (spacing: 10) {
                    Text("TrashSnap")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.brandTeal)
                    
                    Text("Take a picture of your trash and \nfind out what type it is!")
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
                            .overlay{
                                Rectangle()
                                    .stroke(.brandTeal, lineWidth: 2)
                            }
                    } else {
                        ImagePlaceholderView()
                    }
                }
                
                HStack{
                    // Photo source
                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                        ImageSourceLabel(systemImage: "photo.on.rectangle")
                    }
                    .frame(width: 101)
                    .onChange(of: viewModel.selectedPhotoItem) {
                        Task {
                            await viewModel.loadSelectedPhoto()
                        }
                    }
                }
                
                // Classify Button
                Button {
                    viewModel.classifySelectedImage()
                    if viewModel.classificationResult != nil {
                            showResult = true
                        }
                } label: {
                    Text(viewModel.isClassifying ? "Classifying..." : "Classify")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 224, minHeight: 58)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    viewModel.selectedImage == nil ? Color.gray.opacity(0.38) : .brandTeal
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.selectedImage == nil || viewModel.isClassifying)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .padding(.horizontal, 24)
            .navigationDestination(
                isPresented: $showResult
            ) {
                if let result = viewModel.classificationResult,
                   let image = viewModel.selectedImage {
                    ResultView(
                        image: image,
                        result: result
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
