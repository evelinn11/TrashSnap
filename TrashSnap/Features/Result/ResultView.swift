//
//  ResultView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//
import SwiftUI
import UIKit

struct ResultView: View {

    let image: UIImage
    let result: ClassificationResult

    private var otherPredictions: [Prediction] {
        Array(result.predictions.dropFirst())
    }

    var body: some View {
        List {
            // Image
            Section {
                HStack {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 224, height: 224)
                        .clipped()
                        .overlay{
                            Rectangle()
                                .stroke(.brandTeal, lineWidth: 2)
                        }

                    Spacer()
                }
                .listRowSeparator(.hidden)
            }


            // Top Prediction
            Section {
                VStack(spacing: 6) {
                    Text("Top Prediction")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(result.topPrediction.label.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.brandTeal)

                    Text(formattedProbability(result.topPrediction.probability))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)
            }


            // Other Possibilities
            Section("Other Possibilities") {
                ForEach(otherPredictions) { prediction in
                    HStack {
                        Text(prediction.label.capitalized)
                        Spacer()
                        Text(formattedProbability(prediction.probability))
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Classification Result")
        .navigationBarTitleDisplayMode(.inline)
    }


    private func formattedProbability(
        _ probability: Double
    ) -> String {

        let percentage = probability * 100

        if percentage > 0 &&
            percentage < 0.01 {

            return "<0.01%"
        }

        return String(
            format: "%.2f%%",
            percentage
        )
    }
}
