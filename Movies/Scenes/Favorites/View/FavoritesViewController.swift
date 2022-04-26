//
//  FavoritesViewController.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    private let searchViewController = UISearchController()
    private var inputQuery = ""
    lazy var viewModel: FavoriteViewModel = {
        FavoriteViewModel(searchApi: FavoriteApi())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        setupViewModel()
    }

    //MARK: - Setup Viewmodel
    func setupViewModel() {
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
                    self?.collectionView.setEmptyView(message: "Loading...")
                } else {
                    self?.collectionView.restore()
                }
            }
        }
        viewModel.reloadCollectionView = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if (self?.viewModel.numberOfItems)! == 0 {
                    self?.collectionView.setEmptyView(message: "No Favorited Movie")
                }
            }
        }

        viewModel.getData()

    }


    // MARK: - CollectionView Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionViewCell", for: indexPath) as! FavoriteCollectionViewCell
        cell.favoriteItemViewModel = viewModel.getItemViewModel(at: indexPath)
        cell.didTapFavorite = {
            self.viewModel.favoriteMovieAction(at: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: 280)
    }


}

// MARK: - Search View Controller
extension FavoritesViewController: UISearchBarDelegate {
    func setupSearchBar() {
        navigationItem.searchController = searchViewController
        searchViewController.searchBar.delegate = self
        searchViewController.searchBar.searchTextField.backgroundColor = UIColor(named: "SearchBarColor")
        self.definesPresentationContext = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }

        inputQuery = text
        viewModel.removeAllSearchResult()

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchMovie), object: nil)
        self.perform(#selector(self.searchMovie), with: nil, afterDelay: 1.3)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.getData()
    }

    @objc func searchMovie() {
        viewModel.searchMovie(query: inputQuery)
    }
}
