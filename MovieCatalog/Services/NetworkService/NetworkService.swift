//
//  NetworkService.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func searchMovies(query: String, page: Int) async throws -> [Movie]
}

final class NetworkService: NetworkServiceProtocol {
    
    private let apiKey = "1a2ba2fd-5514-487f-bf0f-4a5354be7c4d"
    private let baseURL = "https://kinopoiskapiunofficial.tech/api"

    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        // Используем коллекцию ТОП-250 популярных фильмов Кинопоиска
        let urlString = "\(baseURL)/v2.2/films/collections?type=TOP_250_MOVIES&page=\(page)"
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decodedData.items
    }

    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        let urlString = "\(baseURL)/v2.1/films/search-by-keyword?keyword=\(encodedQuery)&page=\(page)"
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONDecoder().decode(MovieSearchResponse.self, from: data)
        return decodedData.films
    }
}
