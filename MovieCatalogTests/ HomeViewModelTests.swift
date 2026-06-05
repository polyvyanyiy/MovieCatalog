//
//  HomeViewModelTests.swift
//  MovieCatalogTests
//
//  Created by Иван on 05.06.2026.
//

import XCTest
import Observation
@testable import MovieCatalog

final class HomeViewModelTests: XCTestCase {
    
    // Свойства, которые будут пересоздаваться перед каждым тестом
    private var sut: HomeViewModel! // SUT — Subject Under Test (тестируемый объект)
    private var mockService: MockNetworkService!

    // Метод вызывается ПЕРЕД каждым индивидуальным тестом
    @MainActor
    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        // Инициализируем ViewModel, явно передавая mock-сервис
        sut = HomeViewModel(networkService: mockService)
    }

    // Метод вызывается ПОСЛЕ каждого индивидуального теста
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // ТЕСТ 1: Проверяем начальное состояние ViewModel при старте
    func test_init_initialStateIsEmpty() {
        XCTAssertTrue(sut.movies.isEmpty, "Изначально список фильмов должен быть пустым")
        XCTAssertFalse(sut.isLoading, "Изначально статус загрузки должен быть false")
        XCTAssertEqual(sut.searchText, "", "Изначально строка поиска должна быть пустой")
        XCTAssertEqual(sut.selectedSortOption, .none, "Изначально сортировка должна быть отключена")
    }

    // ТЕСТ 2: Проверяем успешную загрузку первой страницы популярных фильмов
    @MainActor
    func test_loadNextPage_successfulDataFetch() async {
        // Given (Дано): Изначально список пуст (проверено в setUp)
        
        // When (Когда): Вызываем асинхронный метод загрузки страницы
        await sut.loadNextPage()
        
        // Then (Тогда): Проверяем результаты
        XCTAssertFalse(sut.movies.isEmpty, "После загрузки массив фильмов не должен быть пустым")
        XCTAssertEqual(sut.movies.count, 3, "Mock-файл содержит ровно 3 фильма, ожидаем их загрузку")
        XCTAssertEqual(sut.movies.first?.title, "Побег из Шоушенка", "Первым фильмом должен быть Побег из Шоушенка")
        XCTAssertFalse(sut.isLoading, "После завершения запроса isLoading должен вернуться в false")
    }

    // ТЕСТ 3: Проверяем корректную работу поиска по ключевому слову
    @MainActor
    func test_search_returnsFilteredResults() async {
        // Given: Вводим поисковый запрос "Брат"
        sut.searchText = "Брат"
        
        // When: Запускаем поиск
        await sut.search()
        
        // Then: Проверяем, что вернулся только один фильм, соответствующий запросу
        XCTAssertEqual(sut.movies.count, 1, "Поиск по слову 'Брат' должен вернуть ровно 1 фильм")
        XCTAssertEqual(sut.movies.first?.title, "Брат", "Найденный фильм должен называться 'Брат'")
    }

    // ТЕСТ 4: Проверяем сброс поиска и возвращение к списку популярных
    @MainActor
    func test_clearSearch_resetsStateAndLoadsPopular() async {
        // Given: Имитируем, что пользователь что-то искал и в массиве лежат результаты поиска
        sut.searchText = "Брат"
        await sut.search()
        XCTAssertEqual(sut.movies.count, 1) // Убедились, что в массиве сейчас только "Брат"
        
        // When: Очищаем поиск через наш метод сброса
        await sut.clearSearch()
        
        // Then: Проверяем, что состояние обнулилось и загрузился полный дефолтный список (3 фильма)
        XCTAssertEqual(sut.searchText, "", "Строка поиска должна стать пустой")
        XCTAssertEqual(sut.movies.count, 3, "Массив должен снова наполниться популярными фильмами из моков")
    }
    
    // ТЕСТ 5: Проверяем работу вычисляемого свойства сортировки по рейтингу
    @MainActor
    func test_sortedMovies_correctlySortsByRating() async {
        // Given: Загружаем базовый список (Побег из Шоушенка - 9.1, Зеленая миля - 9.1, Брат - 8.3)
        await sut.loadNextPage()
        
        // When: Включаем сортировку "Рейтинг: сначала низкие"
        sut.selectedSortOption = .ratingLow
        
        // Then: Фильм "Брат" с самым низким рейтингом (8.3) должен оказаться на первом месте в sortedMovies
        XCTAssertEqual(sut.sortedMovies.first?.title, "Брат", "При сортировке по возрастанию рейтинга 'Брат' должен быть первым")
    }
}
