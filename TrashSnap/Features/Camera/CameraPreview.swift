//
//  CameraPreview.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 31/08/26.
//

import SwiftUI
import AVFoundation

// swiftui does not have a native view that sirectly displays AVCaptureSession
// use AVCaptureVideoPreviewLayer and UIViewRepresentable as bridge
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
