//
//  MovieDetailView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    
    @State private var viewModel: MovieDetailViewModel
    
    init(movie: Movie) {
        self.movie = movie
        self._viewModel = State(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ZStack {
            // Постер на весь экран
            CachedAsyncImage(url: movie.posterURL, isBackground: true)
                .ignoresSafeArea()
            
            // Интерфейс (поверх экрана)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Выдвигаем фон картинки
                    Spacer()
                        .frame(height: 300)
                    
                    // Основное описание
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Заголовок и Год
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text("Год выпуска: \(movie.releaseDate)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Рейтинг и кнопка Избранного
                        HStack {
                            // Рейтинг Кинопоиска
                            HStack(spacing: 2) {
                                // Звездочки
                                RatingStarsView(rating: movie.voteAverage)
                                Spacer()
                                // Оценка
                                Text(String(format: "%.1f", movie.voteAverage))
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.14))
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            // Кнопка Избранного
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.toggleFavorite()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isFavorite ? .red : .white)
                                    Text(viewModel.isFavorite ? "В избранном" : "В избранное")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.isFavorite ? .red.opacity(0.2) : .white.opacity(0.12))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Приоритет если добавили в избранное
                        if viewModel.isFavorite {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Приоритет в списке Избранного:")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Picker("Приоритет", selection: $viewModel.priority) {
                                    Text("Низкий").tag(0)
                                    Text("Средний").tag(1)
                                    Text("Высокий").tag(2)
                                }
                                .pickerStyle(.segmented)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Описание сюжета
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Описание")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            
                            Text(movie.overview.isEmpty ? "Описание фильма отсутствует." : movie.overview)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(6)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .black.opacity(0.0),
                                .black.opacity(0.85),
                                .black.opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .background(.ultraThinMaterial.opacity(0.5))
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar) 
        .onAppear {
            viewModel.checkIfFavorite()
        }
    }
}


//#Preview {
//    NavigationStack {
//        MovieDetailView(movie: Movie(
//            id: 1,
//            title: "Брат",
//            overview: "Демобилизованный из армии Данила Багров возвращается в родной городок. Но скучная жизнь российской провинции не устраивает его, и он решается поехать в Петербург, где процветает его старший брат.",
//            posterPath: nil,
//            releaseDate: "1997",
//            voteAverage: 8.3
//        ))
//    }
//}
