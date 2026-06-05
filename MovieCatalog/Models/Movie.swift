//
//  Movie.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation

// Список популярных
struct MovieResponse: Decodable {
    let total: Int
    let totalPages: Int
    let items: [Movie]
}

// Поиск по ключевым
struct MovieSearchResponse: Decodable {
    let keyword: String
    let pagesCount: Int
    let films: [Movie]
}

// Основная модель
struct Movie: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterURLString: String?
    let releaseDate: String
    let voteAverage: Double
    var priority: Int = 0

    var posterURL: URL? {
        guard let urlString = posterURLString else { return nil }
        return URL(string: urlString)
    }

    enum CodingKeys: String, CodingKey {
        case id = "kinopoiskId"
        case filmId
        case title = "nameRu"
        case overview = "description"
        case posterURLString = "posterUrlPreview"
        case releaseDate = "year"
        case voteAverage = "ratingKinopoisk"
        case rating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let kinopoiskId = try? container.decode(Int.self, forKey: .id) {
            self.id = kinopoiskId
        } else {
            self.id = try container.decode(Int.self, forKey: .filmId)
        }
        
        self.title = (try? container.decode(String.self, forKey: .title)) ?? "Без названия"
        self.overview = (try? container.decode(String.self, forKey: .overview)) ?? ""
        self.posterURLString = try? container.decode(String.self, forKey: .posterURLString)
        
        // Приводим год к String
        if let yearInt = try? container.decode(Int.self, forKey: .releaseDate) {
            self.releaseDate = String(yearInt)
        } else {
            self.releaseDate = (try? container.decode(String.self, forKey: .releaseDate)) ?? ""
        }
        
        if let ratingDouble = try? container.decode(Double.self, forKey: .voteAverage) {
            self.voteAverage = ratingDouble
        } else if let ratingString = try? container.decode(String.self, forKey: .rating), let ratingDouble = Double(ratingString) {
            self.voteAverage = ratingDouble
        } else {
            self.voteAverage = 0.0
        }
    }
    
    // Инициализатор для создания объектов вручную
    init(id: Int, title: String, overview: String, posterPath: String?, releaseDate: String, voteAverage: Double, priority: Int = 0) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterURLString = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.priority = priority
    }
}
