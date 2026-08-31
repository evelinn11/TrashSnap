//
//  ImageSourceLabel.swift
//  TrashSnap
//
//  Created by Evelin Alim Natadjaja on 31/08/26.
//

import SwiftUI

struct ImageSourceLabel: View {
    let systemImage: String
    
    var body: some View {
        Image(systemName: systemImage)
            .font(.largeTitle)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(.brandTeal)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ImageSourceLabel(systemImage: "photo.on.rectangle")
}
