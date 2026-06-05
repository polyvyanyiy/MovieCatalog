//
//  ImageCacheService.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation
import UIKit

final class ImageCacheService {
    
    static let shared = ImageCacheService(); private init() {}
    
    // Файл менеджер
    private let fileManager = FileManager.default
    // Получаем путь к системной папке Кэша приложения
    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    /// Генерирует уникальное имя файла на основе URL картинки
    private func getCacheURL(for url: URL) -> URL? {
        guard let cacheDir = cacheDirectory else { return nil }
        // Очищаем строку от спецсимволов
        let fileName = url.absoluteString.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return cacheDir.appendingPathComponent(fileName)
    }
    
    /// Извлечение изображения из дискового кэша
    func getImage(for url: URL) -> UIImage? {
        guard let fileURL = getCacheURL(for: url),
              fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    /// Сохранение изображения
    func saveImage(_ image: UIImage, for url: URL) {
        guard let fileURL = getCacheURL(for: url),
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
}
