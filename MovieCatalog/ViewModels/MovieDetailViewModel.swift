//
//  MovieDetailViewModel.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation
import Observation

@Observable
final class MovieDetailViewModel {
    var isFavorite: Bool = false
    var priority: Int = 0 {
        didSet {
            coreDataService.updatePriority(for: movie.id, priority: priority)
        }
    }
    
    private let movie: Movie
    private let coreDataService: CoreDataServiceProtocol
    
    init(movie: Movie, coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.movie = movie
        self.coreDataService = coreDataService
        // Проверка на наличие каталогов в избранном
        checkIfFavorite()
    }
    
    func checkIfFavorite() {
        isFavorite = coreDataService.isFavorite(id: movie.id)
        if isFavorite {
            let favorites = coreDataService.fetchFavorites()
            if let savedMovie = favorites.first(where: { $0.id == movie.id }) {
                self.priority = savedMovie.priority
            }
        }
    }
    
    func toggleFavorite() {
        if isFavorite {
            coreDataService.deleteMovie(withId: movie.id)
            isFavorite = false
            priority = 0
        } else {
            var movieToSave = movie
            movieToSave.priority = priority
            coreDataService.saveMovie(movieToSave)
            isFavorite = true
        }
    }
}
