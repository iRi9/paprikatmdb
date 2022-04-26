//
//  UIImageView+loadThumbnail.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {

    func loadThumbnail(urlString: String) {
        image = nil

        guard let url = URL(string: urlString) else {
            self.image = UIImage(named: "noimg")
            return
        }

        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) {
            image = imageFromCache as? UIImage
            return
        }

        Service.shared.downloadImage(url: url) { [weak self] data, error  in
            guard let self = self else { return }

            if error == nil {
                guard let dataImg = data else { return }

                guard let imageToCache = UIImage(data: dataImg) else { return }

                imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                self.image = UIImage(data: dataImg)
            } else {
                self.image = UIImage(named: "noimg")
            }

        }
    }
}
