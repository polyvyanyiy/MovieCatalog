//
//  FavoritesView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI
import Observation

enum FavoriteSortOption: String, CaseIterable, Identifiable {
    case none = "По умолчанию"
    case ratingHigh = "Рейтинг: сначала высокие"
    case ratingLow = "Рейтинг: сначала низкие"
    
    var id: String { self.rawValue }
}

@Observable
final class FavoritesViewModel {
    var favoriteMovies: [Movie] = []
    var selectedSort: FavoriteSortOption = .none
    // Сортировка
    var sortedFavorites: [Movie] {
        // Проверка приоритетов
        favoriteMovies.sorted { first, second in
            // Высший приоритет
            if first.priority != second.priority {
                return first.priority > second.priority
            }
            // Равные приоритеты
            switch selectedSort {
            case .none:
                return false // Стандратный
            case .ratingHigh:
                return first.voteAverage > second.voteAverage
            case .ratingLow:
                return first.voteAverage < second.voteAverage
            }
        }
    }
    
    private let coreDataService: CoreDataServiceProtocol
    init(coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
    }
    
    func loadFavorites() {
        favoriteMovies = coreDataService.fetchFavorites()
    }
    
    func deleteMovie(at offsets: IndexSet) {
        let currentSortedList = sortedFavorites
        for index in offsets {
            let movie = currentSortedList[index]
            coreDataService.deleteMovie(withId: movie.id)
        }
        loadFavorites()
    }
}

struct FavoritesView: View {
    @State private var viewModel = FavoritesViewModel()
    
    // Читаем настройку темы
    @AppStorage("appThemeSelection") private var appThemeSelection = 0
    private var selectedColorScheme: ColorScheme? {
        if appThemeSelection == 1 { return .light }
        if appThemeSelection == 2 { return .dark }
        return nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteMovies.isEmpty {
                    ContentUnavailableView(
                        "Нет избранных фильмов",
                        systemImage: "heart.slash",
                        description: Text("Добавляйте фильмы в избранное на главном экране.")
                    )
                } else {
                    VStack(spacing: 0) {
                        // Горизонтальная плашка фильтрации по рейтингу
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FavoriteSortOption.allCases) { option in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.selectedSort = option
                                        }
                                    }) {
                                        Text(option.rawValue)
                                            .font(.caption)
                                            .bold(viewModel.selectedSort == option)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(viewModel.selectedSort == option ? Color.orange : Color(.systemGray6))
                                            .foregroundColor(viewModel.selectedSort == option ? .white : .primary)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .background(Color(.systemBackground))
                        
                        // Список избранного
                        List {
                            ForEach(viewModel.sortedFavorites) { movie in
                                VStack(spacing: 0) {
                                    NavigationLink(value: movie) {
                                        FavoriteMovieRow(movie: movie)
                                            .padding(.horizontal, 16)
                                    }
                                    Divider()
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                            }
                            .onDelete(perform: viewModel.deleteMovie)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Избранное")
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
            .onAppear {
                viewModel.loadFavorites()
            }
            .preferredColorScheme(selectedColorScheme)
        }
    }
}

struct FavoriteMovieRow: View {
    let movie: Movie
    
    private var ratingColor: Color {
        if movie.voteAverage >= 7.0 { return .green }
        if movie.voteAverage >= 5.0 { return .orange }
        return .red
    }
    
    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(url: movie.posterURL)
                .frame(width: 60, height: 90)
                .cornerRadius(8)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    // Индикатор приоритета
                    if movie.priority == 2 {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    } else if movie.priority == 1 {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                }
                
                Text(movie.releaseDate.prefix(4))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.1f", movie.voteAverage))
                .font(.subheadline)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(ratingColor.opacity(0.25))
                .foregroundColor(ratingColor)
                .cornerRadius(6)
        }
        .padding(.vertical, 8)
    }
}


//#Preview {
//    FavoriteMovieRow(movie: .init(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil, releaseDate: "2020-01-01", voteAverage: 8.5))
//    FavoriteMovieRow(movie: .init(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil, releaseDate: "2020-01-01", voteAverage: 8.5))
//}
