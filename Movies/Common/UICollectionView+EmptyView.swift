//
//  UICollectionView+EmptyView.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

extension UICollectionView {
    func setEmptyView(message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let lblMessage = UILabel()
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        lblMessage.text = message
        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center

        emptyView.addSubview(lblMessage)

        lblMessage.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        lblMessage.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true

        self.backgroundView = emptyView
    }

    func restore() {
        self.backgroundView = nil
    }
}
