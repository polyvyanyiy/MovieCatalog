//
//  MockNetworkService.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation

// Для тестов с API
final class MockNetworkService: NetworkServiceProtocol {
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        // Имитируем задержку в 2 секунды
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let url = Bundle.main.url(forResource: "movies_mock", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let data = try Data(contentsOf: url)
        let decodedData = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decodedData.items
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        let allMovies = try await fetchPopularMovies(page: 1)
        if query.isEmpty { return allMovies }
        return allMovies.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
