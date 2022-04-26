//
//  FavoriteCollectionViewCell.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

protocol FavoriteCollectionViewItemProtocol {
    var id: Int {get set}
    var title: String {get set}
    var posterUrl: String {get set}
    var posterData: Data {get set}
    var isFavorite: Bool {get set}
}

class FavoriteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleFavoriteLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        containerView.layer.cornerRadius = 5
    }

    var favoriteItemViewModel: FavoriteCollectionViewItemProtocol? {
        didSet {
            if favoriteItemViewModel?.isFavorite == true {
                favoriteImageView.image = UIImage(data: favoriteItemViewModel!.posterData)
            } else {
                favoriteImageView.loadThumbnail(urlString: favoriteItemViewModel!.posterUrl)
            }
            titleFavoriteLabel.text = favoriteItemViewModel?.title

            if favoriteItemViewModel?.isFavorite == true {
                favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(UIColor(named: "Favorited")!, renderingMode: .alwaysOriginal), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(UIColor(named: "NotFavorited")!, renderingMode: .alwaysOriginal), for: .normal)
            }
        }
    }
    var didTapFavorite: (() -> Void)?

    @IBAction func favoriteAction(_ sender: Any) {
        didTapFavorite?()
    }
}
