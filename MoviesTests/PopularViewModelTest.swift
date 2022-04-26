//
//  PopularViewModelTest.swift
//  MoviesTests
//
//  Created by Giri Bahari on 25/04/22.
//

import XCTest
@testable import Movies

class PopularViewModelTest: XCTestCase {
    var sut: PopularViewModel!
    var mockApi: MockApi!
    var movieCategory: String!

    override func setUp() {
        super.setUp()
        mockApi = MockApi()
        sut = PopularViewModel(api: mockApi)
        movieCategory = "popular"
    }

    override func tearDown() {
        sut = nil
        mockApi = nil
        movieCategory = nil
        super.tearDown()
    }

    func test_fetch_movie_success() {

        // When
        sut.fetchMovie(category: movieCategory, page: 1)

        // Result
        XCTAssert(mockApi.isFetchMovieCalled)

    }

    func test_fetch_movie_failed() {
        // Given
        let error = ApiError.invalidService

        // When
        sut.fetchMovie(category: movieCategory, page: 1)
        mockApi.fetchMovieFailed()

        // Result
        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }

    func test_loading_when_fetch_movie() {
        // Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut?.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }

        // When
        sut.fetchMovie(category: movieCategory, page: 1)
        XCTAssertTrue( loadingStatus )

        // Then
        mockApi.fetchMovieSuccess()
        XCTAssertFalse( loadingStatus )

        wait(for: [expect], timeout: 1.0)

    }
}

class MockApi: PopularApiProtocol {

    var isFetchMovieCalled = false

    var completeClosure: ((Bool, [Movie], ApiError?) -> Void)!
    var completeMovies = [Movie]()

    func fetch(category: String, page: Int, completion: @escaping (Bool, [Movie], ApiError?) -> Void) {
        isFetchMovieCalled = true
        completeClosure = completion
    }

    func fetchMovieSuccess() {
        completeClosure(true, completeMovies, nil)
    }

    func fetchMovieFailed() {
        completeClosure(false, completeMovies, .invalidService)
    }
}
