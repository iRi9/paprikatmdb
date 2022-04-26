//
//  FilterViewController.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

protocol FilterCategoryProtocol {
    func didSelectCategory(category: Int)
}

class FilterViewController: UITableViewController {

    var delegate: FilterCategoryProtocol?
    var selectedCategory: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Category"
        self.tableView.allowsMultipleSelection = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieCategory.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = MovieCategory(rawValue: indexPath.row)?.display

        if selectedCategory != nil, selectedCategory == indexPath.row {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            delegate?.didSelectCategory(category: indexPath.row)
            dismiss(animated: true)
        }
    }

}
