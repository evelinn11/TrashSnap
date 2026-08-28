//
//  ContentView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    // initialize view model
    @StateObject private var viewModel = MainViewModel()
    
    // navigation to result view
    @State private var showResult = false
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                Text("TrashSnap")
                    .font(.title)
                
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 250)
                        .overlay {
                            VStack (spacing: 8){
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                
                                Text("No Image selected")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
                
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                }
                .onChange(of: viewModel.selectedPhotoItem) {
                    Task {
                        await viewModel.loadSelectedPhoto()
                    }
                }
                
                Button("Classify"){
                    viewModel.classifySelectedImage()
                    if viewModel.classificationResult != nil {
                            showResult = true
                        }
                }
                .disabled(viewModel.selectedImage == nil || viewModel.isClassifying)
                
                if viewModel.isClassifying {
                    ProgressView("Classifying...")
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .padding()
            .navigationDestination(
                isPresented: $showResult
            ) {
                if let result = viewModel.classificationResult {
                    ResultView(
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
