//
//  CachedAsyncImage.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    var isBackground: Bool = false
    
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1/2, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    .if(isBackground) { view in
                        view
                            .blur(radius: 1) // Размываем
                            .overlay(Color.black.opacity(0.65)) // Затемняем
                            .clipped() // Обрезаем края
                    }
                } else if isLoading {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    // Заглушка, если картинка не загрузилась или URL пустой
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "film")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .task {
            await loadImage()
        }
    }
    
    // Подгрузка изображения
    private func loadImage() async {
        guard let url = url else { return }
        
        // Проверка дискового кэша
        if let cachedImage = ImageCacheService.shared.getImage(for: url) {
            self.image = cachedImage
            return
        }
        
        // Если нет, качаем из сети
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                // Сохраняем скачанный постер на диск
                ImageCacheService.shared.saveImage(downloadedImage, for: url)
                self.image = downloadedImage
            }
        } catch {
            print("Ошибка загрузки картинки: \(error)")
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
