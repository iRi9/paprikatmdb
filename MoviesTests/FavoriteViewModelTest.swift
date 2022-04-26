//
//  FavoriteViewModelTest.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import XCTest
@testable import Movies

class FavoriteViewModelTest: XCTestCase {
    var sut: FavoriteViewModel!
    var mockApi: FavoriteMockApi!
    var query: String!

    override func setUp() {
        super.setUp()
        mockApi = FavoriteMockApi()
        sut = FavoriteViewModel(searchApi: mockApi)
        query = "Spiderman"
    }

    override func tearDown() {
        sut = nil
        mockApi = nil
        query = nil
        super.tearDown()
    }

    func test_search_movie_success() {
        sut.searchMovie(query: query)

        XCTAssert(mockApi.isSearchMovieCalled)
    }

    func test_search_movie_failed() {
        let error = ApiError.invalidService

        sut.searchMovie(query: "")
        mockApi.fetchMovieFailed()

        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }

    func test_loading_when_search_movie() {
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut?.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }

        sut.searchMovie(query: query)
        XCTAssertTrue(loadingStatus)

        mockApi.fetchMovieSuccess()
        XCTAssertFalse(loadingStatus)

        wait(for: [expect], timeout: 1.0)
    }

}

class FavoriteMockApi: FavoriteSearchApiProtocol {

    var isSearchMovieCalled = false

    var completeClosure: ((Bool, [FavoriteMovie], ApiError?) -> Void)!
    var completeMovies = [FavoriteMovie]()

    func fetchMovieSuccess() {
        completeClosure(true, completeMovies, nil)
    }

    func fetchMovieFailed() {
        completeClosure(false, completeMovies, .invalidService)
    }
    func fetch(query: String, page: Int, completion: @escaping (Bool, [FavoriteMovie], ApiError?) -> Void) {
        isSearchMovieCalled = true
        completeClosure = completion
    }
}
