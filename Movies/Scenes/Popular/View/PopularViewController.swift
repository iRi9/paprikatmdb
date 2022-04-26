//
//  PopularViewController.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

class PopularViewController: UIViewController, UITableViewDataSource, FilterCategoryProtocol {

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var selectedCategory = 0
    lazy var viewModel: PopularViewModel = {
        PopularViewModel(api: PopularApi())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewModel()
    }

    //MARK: - Setup ViewModel
    func setUpViewModel() {
        viewModel.showAlert = { [weak self] in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(title: "Info", message: message)
                }
            }
        }
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.tableView.setEmptyView(message: "Loading...")
                } else {
                    self?.tableView.restore()
                }
            }
        }
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.fetchMovie(category: MovieCategory.popular.path, page: 1)
    }

    //MARK: - Filter Action
    @IBAction func didTapFilter(_ sender: Any) {
        let filterCategoryViewController = FilterViewController()
        filterCategoryViewController.delegate = self
        filterCategoryViewController.selectedCategory = selectedCategory
        let navigationController = UINavigationController(rootViewController: filterCategoryViewController)
        present(navigationController, animated: true)
    }

    func didSelectCategory(category: Int) {
        selectedCategory = category
        filterButton.setTitle("Filtered by: \(MovieCategory(rawValue: selectedCategory)?.display ?? "-")", for: .normal)
        viewModel.fetchMovie(category: MovieCategory(rawValue: selectedCategory)!.path, page: 1)
    }

    //MARK: - Table view setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        cell.popularCellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
}
