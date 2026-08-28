//
//  ContentView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack (spacing: 20){
            Text("TrashSnap")
                .font(.title)
            
            Button("Test Pixel Buffer") {
                guard let image = UIImage(
                    named: "testGlass"
                ) else {
                    print("Failed to load test image")
                    return
                }
                
                do {
                    let pixelBuffer = try ImagePreprocessor.makePixelBuffer(from: image)
                    
                    let classifier = try TrashClassifierService()
                    
                    let result = try classifier.classify(pixelBuffer: pixelBuffer)
                    
                    print("Top prediction: ", result.topPrediction.label)
                    
                    print("Confidence: ", String(
                        format: "%.2f",
                        result.topPrediction.probability * 100
                    ))
                    
                    print("\nAll predictions:")

                    for prediction in result.predictions {

                        print(
                            "\(prediction.label): " +
                            String(
                                format: "%.2f%%",
                                prediction.probability * 100
                            )
                        )
                    }
                    
                } catch {
                    print("Classification failed", error)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
