//
//  MovieGridSkeleton.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct MovieGridSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заглушка под постер
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 250)
            
            // Заглушка под название фильма
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 16)
            
            // Заглушка под год
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 14)
        }
        .shimmer(if: true)
    }
}
