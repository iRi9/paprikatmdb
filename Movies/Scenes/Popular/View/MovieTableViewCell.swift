//
//  MovieTableViewCell.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

protocol PopularTableViewCellProtocol {
    var id: Int {get set}
    var title: String {get set}
    var releaseYear: String {get set}
    var overview: String {get set}
    var posterUrl: String {get set}
    var posterData: Data {get set}
}

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    var popularCellViewModel: PopularCellViewModel? {
        didSet {
            titleLabel.text = popularCellViewModel?.title
            releaseYearLabel.text = popularCellViewModel?.releaseYear
            descLabel.text = popularCellViewModel?.overview
            posterImageView.loadThumbnail(urlString: popularCellViewModel!.posterUrl)
        }
    }

    
}
