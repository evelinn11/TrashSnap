//
//  ImagePreprocessor.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import UIKit
import CoreML

// custom error enum to define possible failures
enum ImagePreprocessorError: Error {
    case missingCGImage
    case failedToCreatePixelBuffer
}

// utility responsible to prepare images for Core ML UIIMage -> CGImage -> resize -> CVPixelBuffer
struct ImagePreprocessor {
    static func makePixelBuffer(from image: UIImage) throws -> CVPixelBuffer {
        
        // convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            throw ImagePreprocessorError.missingCGImage
        }
        
        // turn CGImage to an image feature suitable for ML
        let featureValue = try MLFeatureValue(
            cgImage: cgImage,
            pixelsWide: 224,
            pixelsHigh: 224,
            pixelFormatType: kCVPixelFormatType_32BGRA,
            options: nil
        )
        
        // extrach the CVPixelBufer
        guard let pixelBuffer = featureValue.imageBufferValue else {
            throw ImagePreprocessorError.failedToCreatePixelBuffer
        }
        
        return pixelBuffer
    }
}

