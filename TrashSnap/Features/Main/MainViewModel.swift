//
//  MainViewModel.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import UIKit
import Combine
import PhotosUI
import _PhotosUI_SwiftUI

// MainActor means this ViewModel's state is managed on the main thread
// ObservableObject means SwiftUI can observe this object for state changes
@MainActor
final class MainViewModel: ObservableObject {
    // what did user select
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    // what image did the user choose
    @Published var selectedImage: UIImage?
    
    // what did the ML model predict
    @Published var classificationResult: ClassificationResult?
    
    // is inference currently running
    @Published var isClassifying = false
    
    // did something go wrong
    @Published var errorMessage: String?
    
    private var classifier: TrashClassifierService?
    
    // load model once when the ViewModel is created
    init() {
        do {
            classifier = try TrashClassifierService()
        } catch {
            classifier = nil
            errorMessage = "Failed to load classification model."
        }
    }
    
    /// Function for loading selected image from selected item in PhotoPicker
    func loadSelectedPhoto() async {
        guard let selectedPhotoItem else {
            return
        }
        
        do {
            guard let data = try await selectedPhotoItem.loadTransferable(type: Data.self)
            else {
                errorMessage = "Failed to load selected image"
                return
            }
            
            guard let image = UIImage(data: data) else {
                errorMessage = "Failed to create image"
                return
            }
            
            selectedImage = image
            classificationResult = nil
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load selected image"
        }
    }
    
    /// Function for the complete process: checking image and loaded model, call the pixell buffer, call the classifying method
    func classifySelectedImage() {
        guard let selectedImage else {
            errorMessage = "Please select an image first."
            return
        }
        
        guard let classifier else {
            errorMessage = "Classification model is unavailable."
            return
        }
        
        // No matter how this function exits, reset isClassifying to false afterward
        isClassifying = true
        errorMessage = nil
        
        defer {
            isClassifying = false
        }
        
        do {
            let pixelBuffer = try ImagePreprocessor.makePixelBuffer(from: selectedImage)
            classificationResult = try classifier.classify(pixelBuffer: pixelBuffer)
        } catch {
            errorMessage = "Failed to classify image."
        }
    }
    
    func setSelectedImage(
        _ image: UIImage
    ) {

        selectedImage = image
        classificationResult = nil
        errorMessage = nil
    }
}
