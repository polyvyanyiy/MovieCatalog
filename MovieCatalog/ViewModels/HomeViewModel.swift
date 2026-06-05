//
//  HomeViewModel.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation
import Observation

enum MovieSortOption: String, CaseIterable, Identifiable {
    case none = "Без сортировки"
    case ratingHigh = "Рейтинг: сначала высокие"
    case ratingLow = "Рейтинг: сначала низкие"
    case yearNew = "Год: сначала новые"
    case yearOld = "Год: сначала старые"
    
    var id: String { self.rawValue }
}

@Observable
final class HomeViewModel {
    var movies: [Movie] = []
    var isLoading = false
    var searchText = ""
    
    var selectedSortOption: MovieSortOption = .none
    var sortedMovies: [Movie] {
        switch selectedSortOption {
        case .none:
            return movies
        case .ratingHigh:
            return movies.sorted { $0.voteAverage > $1.voteAverage }
        case .ratingLow:
            return movies.sorted { $0.voteAverage < $1.voteAverage }
        case .yearNew:
            return movies.sorted { $0.releaseDate > $1.releaseDate }
        case .yearOld:
            return movies.sorted { $0.releaseDate < $1.releaseDate }
        }
    }
    
    private let networkService: NetworkServiceProtocol
    private var currentPage = 1
    private var isLastPage = false
    
    // Подмена для тестов с API (NetworkService)
    init(networkService: NetworkServiceProtocol = MockNetworkService()) {
        self.networkService = networkService
    }
    
    @MainActor
    func loadNextPage() async {
        guard !isLoading && !isLastPage else { return }
        isLoading = true
        
        do {
            let newMovies = try await networkService.fetchPopularMovies(page: currentPage)
            if newMovies.isEmpty {
                isLastPage = true
            } else {
                let uniqueNewMovies = newMovies.filter { newMovie in
                    !movies.contains(where: { $0.id == newMovie.id })
                }
                
                if uniqueNewMovies.isEmpty && !movies.isEmpty {
                    isLastPage = true
                } else {
                    movies.append(contentsOf: uniqueNewMovies)
                    currentPage += 1
                }
            }
        } catch {
            print("Ошибка загрузки: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func search() async {
        guard !searchText.isEmpty else { return }
        isLoading = true
        isLastPage = true
        do {
            movies = try await networkService.searchMovies(query: searchText, page: 1)
        } catch {
            print("Ошибка поиска: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func clearSearch() async {
        searchText = ""
        movies = []
        currentPage = 1
        isLastPage = false
        await loadNextPage()
    }
}
