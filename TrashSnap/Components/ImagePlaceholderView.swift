//
//  ImagePlaceholderView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI

struct ImagePlaceholderView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray6))

            VStack(spacing: 8) {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(.largeTitle)

                VStack{
                    Text("No image yet")
                        .font(.caption)

                    Text("Choose a photo to classify")
                        .font(.caption)
                }
            }
        }
        .frame(width: 224, height: 224)
        .overlay {
            Rectangle()
                .stroke(
                    Color.black,
                    lineWidth: 2
                )
        }
    }
}
#Preview {
    ImagePlaceholderView()
}
