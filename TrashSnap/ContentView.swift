//
//  ContentView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI

struct ContentView: View {
    
    // initialize view model
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack (spacing: 20){
            Text("TrashSnap")
                .font(.title)
            
            Button("Load Test Image") {
                guard let image = UIImage(
                    named: "testGlass"
                ) else {
                    return
                }
                
                viewModel.selectedImage = image
            }
            
            Button("Classify"){
                viewModel.classifySelectedImage()
            }
            .disabled(viewModel.selectedImage == nil || viewModel.isClassifying)
            
            if viewModel.isClassifying {
                ProgressView("Classifying...")
            }
            
            if let result = viewModel.classificationResult {
                
                Text("Prediction: \(result.topPrediction.label)")
                
                Text(String(format: "Confidence: %.2f%%", result.topPrediction.probability * 100))
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
