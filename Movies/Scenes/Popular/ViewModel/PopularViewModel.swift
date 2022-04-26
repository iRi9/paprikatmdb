//
//  PopularViewModel.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import Foundation

class PopularViewModel {
    var api: PopularApiProtocol
    var reloadTableView: (() -> Void)?
    var showAlert: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?

    private var popularCellViewModel: [PopularCellViewModel] = [PopularCellViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlert?()
        }
    }
    var numberOfCells: Int {
        return popularCellViewModel.count
    }

    init(api: PopularApiProtocol = PopularApi()) {
        self.api = api
    }

    func fetchMovie(category: String, page: Int) {
        isLoading = true

        api.fetch(category: category, page: page) { status, movies, error in
            self.isLoading = false
            if let error = error {
                self.alertMessage = error.rawValue
            } else {
                self.processMoviesViewModel(movies)
            }
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> PopularCellViewModel {
        popularCellViewModel[indexPath.row]
    }

    private func processMoviesViewModel(_ movies: [Movie]) {
        var tempCellViewModels = [PopularCellViewModel]()
        for movie in movies {
            tempCellViewModels.append(createMovieCellViewModel(movie: movie))
        }
        self.popularCellViewModel = tempCellViewModels
    }

    private func createMovieCellViewModel(movie: Movie) -> PopularCellViewModel {
        let releaseYear = movie.releaseDate.split(separator: "-")

        return PopularCellViewModel(id: movie.id,title: movie.title, releaseYear: String(releaseYear[0]), overview: movie.overview, posterUrl: "https://image.tmdb.org/t/p/w185\(movie.posterPath)", posterData: Data())
    }

}

struct PopularCellViewModel: PopularTableViewCellProtocol {
    var id: Int
    var title: String
    var releaseYear: String
    var overview: String
    var posterUrl: String
    var posterData: Data
}
