//
//  TrashClassifierService.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import CoreML
import CoreVideo
import Foundation

enum TrashClassifierError: Error {
    case noPrediction
}

// auto generated class for the TrashClassifier.mlpackage
final class TrashClassifierService {
    private let model: TrashClassifier
    
    // label
    private let classes = ["cardboard", "glass", "metal", "paper", "plastic", "trash"]
    
    init() throws {
        // creates the configuration used to load the model
        let configuration = MLModelConfiguration()
        
        // load the model
        self.model = try TrashClassifier(configuration: configuration)
    }
    
    /// Function for classfying image converted from pixel buffer, read output, convert output to probabilities
    func classify(pixelBuffer: CVPixelBuffer) throws -> ClassificationResult {
        // generate output from model prediction
        let output = try model.prediction(image: pixelBuffer)
        
        // read the output
        let multiArray = output.var_822
        
        // convert multi array to double for easier work
        var logits: [Double] = []
        for index in 0..<multiArray.count {
            logits.append(multiArray[index].doubleValue)
        }
        
        // convert logits to probabilities
        let probabilities = softmax(logits)
        
        // combine each class with its probability
        // zip pairs two array and map turn it to Swift object
        let predictions = zip(classes, probabilities).map { label, probability in
            Prediction(
                label: label,
                probability: probability
            )
        }
        // sorts from highest probabilities to the lowest
        .sorted {
            $0.probability > $1.probability
        }
        
        guard let topPrediction = predictions.first else {
            throw TrashClassifierError.noPrediction
        }
        
        return ClassificationResult(topPrediction: topPrediction, predictions: predictions)
    }
    
    /// Function for converting logits into probabilities with softmax
    private func softmax(_ logits: [Double]) -> [Double] {
        guard let maxLogit = logits.max() else { return [] }
        let exponentials = logits.map { exp($0 - maxLogit)}
        let sum = exponentials.reduce(0, +)
        return exponentials.map { $0 / sum }
    }
}
