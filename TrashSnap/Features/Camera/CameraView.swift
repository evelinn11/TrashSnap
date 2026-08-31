//
//  CameraView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 31/08/26.
//

import SwiftUI

struct CameraView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            // Live camera
            CameraPreview( session: cameraManager.session).ignoresSafeArea()

            // Camera controls
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                        .font(.system(size: 18,weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4))
                        .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Shutter button
                Button {
                    cameraManager.capturePhoto()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 5)
                            .frame(width: 76,height: 76)
                        Circle()
                            .fill(.white)
                            .frame(width: 62, height: 62)
                    }
                }
                .padding(.bottom, 36)
            }


            // Temporary error message
            if let errorMessage =
                cameraManager.errorMessage {

                VStack {

                    Spacer()

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            .black.opacity(0.6)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                        .padding(.bottom, 130)
                }
            }
        }
        .onAppear {
            cameraManager
                .requestPermissionAndStart()
        }
        .onDisappear {
            cameraManager
                .stopSession()
        }
    }
}

#Preview {
    CameraView()
}
