//
//  ShimmerModifier.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .white.opacity(0.5),
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: geometry.size.width * 2) // Делаем градиент шире экрана для разгона
                        .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                    }
                )
                .mask(content)
                .onAppear {
                    // Запуск анимации
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// Вызов одной строчкой
extension View {
    func shimmer(if isEnabled: Bool) -> some View {
        self.modifier(ShimmerModifier(isEnabled: isEnabled))
    }
}
