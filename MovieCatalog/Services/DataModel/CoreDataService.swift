//
//  CoreDataService.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveMovie(_ movie: Movie)
    func deleteMovie(withId id: Int)
    func fetchFavorites() -> [Movie]
    func isFavorite(id: Int) -> Bool
    func updatePriority(for movieId: Int, priority: Int)
}

final class CoreDataService: CoreDataServiceProtocol {
    static let shared = CoreDataService()
    private let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "MovieModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("Ошибка CoreData: \(error)") }
        }
    }

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveMovie(_ movie: Movie) {
        // Проверяем, нет ли уже такого фильма в базе
        if isFavorite(id: movie.id) { return }
        
        let favorite = FavoriteMovie(context: context)
        favorite.id = Int64(movie.id)
        favorite.title = movie.title
        favorite.overview = movie.overview
        favorite.posterPath = movie.posterURLString
        favorite.releaseDate = movie.releaseDate
        favorite.voteAverage = movie.voteAverage
        favorite.priority = Int16(movie.priority)
        
        saveContext()
    }

    func deleteMovie(withId id: Int) {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Ошибка удаления из CoreData: \(error)")
        }
    }

    func fetchFavorites() -> [Movie] {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.map { favorite in
                Movie(
                    id: Int(favorite.id),
                    title: favorite.title ?? "",
                    overview: favorite.overview ?? "",
                    posterPath: favorite.posterPath,
                    releaseDate: favorite.releaseDate ?? "",
                    voteAverage: favorite.voteAverage,
                    priority: Int(favorite.priority)
                )
            }
        } catch {
            print("Ошибка чтения из CoreData: \(error)")
            return []
        }
    }

    func isFavorite(id: Int) -> Bool {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }

    func updatePriority(for movieId: Int, priority: Int) {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieId)
        if let result = try? context.fetch(request).first {
            result.priority = Int16(priority)
            saveContext()
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста CoreData: \(error)")
            }
        }
    }
}
