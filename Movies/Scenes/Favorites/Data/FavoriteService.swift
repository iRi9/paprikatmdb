//
//  FavoriteService.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import Foundation

protocol FavoriteSearchApiProtocol {
    func fetch(query: String, page: Int, completion: @escaping(_ status: Bool, _ movies: [FavoriteMovie], _ error: ApiError?) -> Void)
}

class FavoriteApi: FavoriteSearchApiProtocol {
    
    func fetch(query: String, page: Int, completion: @escaping (Bool, [FavoriteMovie], ApiError?) -> Void) {
        var components = URLComponents(string: "https://api.themoviedb.org/3/search/movie")!

        components.queryItems = [
            URLQueryItem(name: "api_key", value: Service.shared.apiKey),
            URLQueryItem(name: "language", value: Service.shared.language),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "query", value: "\(query)")
        ]

        let request = URLRequest(url: components.url!)

        Service.shared.call(request: request) { (result: Result<FavoriteMovieResponse, ApiError>) in
            switch result {
            case .success(let data):
                completion(true, data.results, nil)
            case .failure(let error):
                completion(false, [FavoriteMovie](), error)
            }
        }
    }


}
