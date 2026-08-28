//
//  ResultView.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import SwiftUI

struct ResultView: View {

    let result: ClassificationResult

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                Text("Top Prediction")
                    .font(.headline)

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        result.topPrediction.label.capitalized
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    Text(
                        String(
                            format: "%.2f%%",
                            result.topPrediction.probability * 100
                        )
                    )
                    .font(.title2)
                }

                Divider()

                Text("Other Possibilities")
                    .font(.headline)

                VStack(spacing: 16) {

                    ForEach(
                        Array(result.predictions.dropFirst())
                    ) { prediction in

                        HStack {

                            Text(
                                prediction.label.capitalized
                            )

                            Spacer()

                            Text(
                                String(
                                    format: "%.2f%%",
                                    prediction.probability * 100
                                )
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}
