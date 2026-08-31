//
//  CameraManager.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 31/08/26.
//

import AVFoundation
import Combine
import UIKit

final class CameraManager: NSObject, ObservableObject {
    // camera pipeline coordinator, the session connects camera input to whatever output we want
    let session = AVCaptureSession()
    
    // chcek the user's current camera permission
    @Published var authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published var errorMessage: String?
    
    @Published var capturedImage: UIImage?
    
    // used for when user press shutter, attaching the output to the session
    private let photoOutput = AVCapturePhotoOutput()
    
    // create separate queue to let the UI remain responsive
    private let sessionQueue = DispatchQueue(label: "TrashSnap.camera.session")
    
    // prevents from repeatedly adding the same camera input/output every time the screen appears
    private var isConfigured = false
    
    /// Function for handling the different permission states
    func requestPermissionAndStart() {
        switch authorizationStatus {
        
        // immediately start configuring the camera
        case .authorized:
            configureAndStartSession()
        
        // if the user never been asked, produce camera permission dialog
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    self.authorizationStatus = granted ? .authorized : .denied
                }
                
                if granted { self.configureAndStartSession()}
            }
            
        case .denied, .restricted:
            errorMessage = "Camera access is unavailable. Please, enable camera access in your device settings."
            
        @unknown default: errorMessage = "Unknown camera authorization status."
        }
    }
    
    private func configureAndStartSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            if !self.isConfigured {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                
                // for configuration
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                else {
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "Back camera is unavailable."
                    }
                    return
                }
                
                // can't add the camera device directly to the session need to convert physical camera to AVCaptureDeviceInput
                do {
                    let input = try AVCaptureDeviceInput(device: camera)
                    
                    // connect to capture session
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    }
                } catch {
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to configure camera input."
                    }
                    return
                }
                
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                self.session.commitConfiguration()
                self.isConfigured = true
            }
            
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            guard self.session.isRunning else {
                DispatchQueue.main.async {
                    self.errorMessage = "Camera is not ready."
                }
                
                return
            }
            
            let settings = AVCapturePhotoSettings()
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraManager:
    AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            DispatchQueue.main.async {
                self.errorMessage =
                    "Failed to capture photo: \(error.localizedDescription)"
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData)
        else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create captured image."
            }

            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
            print("Photo captured successfully!")
            print("Image size:", image.size)
        }
    }
}
