//
//  RatingStarsView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct RatingStarsView: View {
    let rating: Double
    private let maxStars = 10
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxStars, id: \.self) { index in
                starIcon(for: index)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
    }
    
    // Определение иконки (звездочки)
    private func starIcon(for index: Int) -> Image {
        let starIndex = Double(index)
        
        if rating >= starIndex + 1.0 {
            // Полностью
            return Image(systemName: "star.fill")
        } else if rating >= starIndex + 0.25 && rating < starIndex + 0.75 {
            // Наполовину
            return Image(systemName: "star.leadinghalf.filled")
        } else if rating >= starIndex + 0.75 {
            // Полностью
            return Image(systemName: "star.fill")
        } else {
            // Пустая
            return Image(systemName: "star")
        }
    }
}

//#Preview {
//    VStack(spacing: 10) {
//        RatingStarsView(rating: 8.3)
//    }
//    .padding()
//    .background(Color.black)
//}
