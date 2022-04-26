//
//  FavoriteMovie.swift
//  Movies
//
//  Created by Giri Bahari on 26/04/22.
//

import Foundation

struct FavoriteMovie: Decodable {
    let id: Int
    let posterPath: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        title = try values.decode(String.self, forKey: .title)
    }
}

struct FavoriteMovieResponse: Decodable {
    let page: Int
    let totalResults: Int
    let totalPages: Int

    let results: [FavoriteMovie]

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results = "results"
    }
}
