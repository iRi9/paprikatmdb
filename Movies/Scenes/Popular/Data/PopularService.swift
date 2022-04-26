//
//  PopularService.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import Foundation

enum MovieCategory: Int, CaseIterable {
    case popular
    case nowplaying
    case toprated
    case upcoming

    var display: String {
        switch self {
        case .popular:
            return "Popular"
        case .nowplaying:
            return "Now Playing"
        case .toprated:
            return "Top Rated"
        case .upcoming:
            return "Upcoming"
        }
    }

    var path: String {
        switch self {
        case .popular:
            return "popular"
        case .nowplaying:
            return "now_playing"
        case .toprated:
            return "top_rated"
        case .upcoming:
            return "upcoming"
        }
    }
}

protocol PopularApiProtocol {
    func fetch(category: String, page: Int, completion: @escaping(_ status: Bool, _ movies: [Movie], _ error: ApiError?) -> Void)
}

class PopularApi: PopularApiProtocol {
    func fetch(category: String, page: Int, completion: @escaping (Bool, [Movie], ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/\(category)")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: Service.shared.apiKey),
            URLQueryItem(name: "language", value: Service.shared.language),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        let request = URLRequest(url: components.url!)

        Service.shared.call(request: request) { (result: Result<MovieResponse, ApiError>) in
            switch result {
            case .success(let data):
                completion(true, data.movies, nil)
            case .failure(let error):
                completion(false, [Movie](), error)
            }
        }
    }
}
