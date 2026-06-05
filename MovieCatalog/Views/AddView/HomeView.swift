//
//  HomeView.swift
//  MovieCatalog
//
//  Created by Иван on 05.06.2026.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    // Настройку темы
    @AppStorage("appThemeSelection") private var appThemeSelection = 0
    private var selectedColorScheme: ColorScheme? {
        if appThemeSelection == 1 { return .light }
        if appThemeSelection == 2 { return .dark }
        return nil // nil означает системную тему
    }
    
    // Настройка колонок
    @AppStorage("gridColumnsCount") private var gridColumnsCount = 2
    // Расчет сетки
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: gridColumnsCount)
    }
    // Расчет высоты
    private var cellHeight: CGFloat {
        switch gridColumnsCount {
        case 1: return 400 // Крупный баннер 1х1
        case 3: return 160 // Компактная ячейка 3х3
        default: return 250 // Стандартный размер для 2х2
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MovieSortOption.allCases) { option in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectedSortOption = option
                                    }
                                }) {
                                    Text(option.rawValue)
                                        .font(.subheadline)
                                        .bold(viewModel.selectedSortOption == option)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        // Подсветка активного фильтра
                                        .background(viewModel.selectedSortOption == option ? Color.blue : Color(.systemGray6))
                                        .foregroundColor(viewModel.selectedSortOption == option ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color(.systemBackground))
                    
                    // Сетка фильмов
                    if viewModel.isLoading && viewModel.movies.isEmpty {
                        // Мерцание
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(0..<6, id: \.self) { _ in
                                MovieGridSkeleton()
                            }
                        }
                        .padding()
                    } else {
                        // Подгрузка
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.sortedMovies) { movie in
                                NavigationLink(value: movie) {
                                    // Передаем динамическую высоту в ячейку
                                    MovieGridCell(movie: movie, height: cellHeight)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if movie == viewModel.movies.last {
                                        Task { await viewModel.loadNextPage() }
                                    }
                                }
                            }
                        }
                        .padding()
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: gridColumnsCount)
                    }
                }
                
                if viewModel.isLoading && !viewModel.movies.isEmpty {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Главная")
            .searchable(text: $viewModel.searchText, prompt: "Поиск фильмов")
            .onChange(of: viewModel.searchText) { _, newValue in
                Task {
                    if newValue.isEmpty {
                        await viewModel.clearSearch()
                    } else {
                        await viewModel.search()
                    }
                }
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
            .task {
                await viewModel.loadNextPage()
            }
            .preferredColorScheme(selectedColorScheme) 
        }
    }
}

// Обновленная ячейка с поддержкой динамической высоты
struct MovieGridCell: View {
    let movie: Movie
    let height: CGFloat // Принимаем высоту снаружи
    @AppStorage("gridColumnsCount") private var gridColumnsCount = 2
    
    // цвет ячеек с рейтенгом
    private var ratingColor: Color {
        if movie.voteAverage >= 7.0 { return .green }
        if movie.voteAverage >= 5.0 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: movie.posterURL)
                    .frame(height: height) // Применяем рассчитанную высоту
                    .cornerRadius(12)
                    .clipped()
                
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ratingColor.opacity(0.45))
                    .cornerRadius(8)
                    .padding(8)
            }
            
            // На сетке 3х3 уменьшаем шрифт заголовков
            Text(movie.title)
                .font(gridColumnsCount == 3 ? .caption.bold() : .headline)
                .lineLimit(1)
            
            if gridColumnsCount < 3 {
                Text(movie.releaseDate.prefix(4))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
