//
//  Prediction.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 28/08/26.
//

import Foundation

// A Prediction represents one class prediction
// e.g: label = glass, probability = 0.9967

struct Prediction: Identifiable {
    let label: String
    let probability: Double
    
    var id: String {
        label
    }
}
