//
//  VisionTrashClassifierService.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 02/09/26.
//

import CoreML
import Vision
import UIKit

enum VisionClassifierError: Error {
    case missingCGImage
    case missingModelOutput
    case noPrediction
}

final class VisionTrashClassifierService {
    
    // store a VNCoreModel
    private let visionModel: VNCoreMLModel
    
    // label
    private let classes = ["cardboard", "glass", "metal", "paper", "plastic", "trash"]
    
    init() throws {
        // creates the configuration used to load the model
        let configuration = MLModelConfiguration()
        
        // load the model
        let coreMLModel = try TrashClassifier(configuration: configuration)
        
        // vision wrapper around existing model
        // now Vision understand that this model can be used inside a Vision request
        self.visionModel = try VNCoreMLModel(for: coreMLModel.model)
    }
    
    func classify(image: UIImage, cropAndScaleOption: VNImageCropAndScaleOption = .scaleFill) throws -> ClassificationResult {
        // convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            throw VisionClassifierError.missingCGImage
        }
        
        // create a vision request
        let request = VNCoreMLRequest(model: visionModel)
        
        // resize image to match model input
        request.imageCropAndScaleOption = cropAndScaleOption
        
        // set orientation
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        // give original image to Vision
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation:orientation, options: [:])
        
        // perform request
        try handler.perform([request])
        
        // because the output is a raw MultiArray (1 x 6), Vision return feature-value observation
        guard let observation = request.results as? [VNCoreMLFeatureValueObservation],
              let observation = observation.first(where: {$0.featureName == "var_822"}),
              let multiArray = observation.featureValue.multiArrayValue
        else {
            throw VisionClassifierError.missingModelOutput
        }
        
        // Convert MLMultiArray to [Double]
        var logits: [Double] = []
        for index in 0..<multiArray.count {
            logits.append(
                multiArray[index].doubleValue
            )
        }

        // Convert logits → probabilities
        let probabilities = softmax(logits)

        // Match each probability to its class
        let predictions = zip(classes, probabilities).map { label, probability in
            Prediction(label: label, probability: probability)
        }
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
