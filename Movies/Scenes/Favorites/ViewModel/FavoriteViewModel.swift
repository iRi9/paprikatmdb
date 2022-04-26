//
//  FavoriteViewModel.swift
//  Movies
//
//  Created by Giri Bahari on 25/04/22.
//

import UIKit
import CoreData

class FavoriteViewModel {
    var searchApi: FavoriteSearchApiProtocol
    var reloadCollectionView: (() -> Void)?
    var showAlert: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?

    private var favoriteItemViewModel: [FavoriteItemViewModel] = [FavoriteItemViewModel]() {
        didSet {
            self.reloadCollectionView?()
        }
    }
    private var localFavorite = [FavoriteItemViewModel]()
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlert?()
        }
    }
    var numberOfItems: Int {
        return favoriteItemViewModel.count
    }

    init(searchApi: FavoriteSearchApiProtocol = FavoriteApi()) {
        self.searchApi = searchApi
    }

    func getData() {
        favoriteItemViewModel = [FavoriteItemViewModel]()
        isLoading = true
        getFavorited { localFavorite in
            DispatchQueue.main.async {
                self.isLoading = false
                self.localFavorite = localFavorite
                self.favoriteItemViewModel = localFavorite
            }
        }
    }

    func searchMovie(query: String) {
        isLoading = true
        favoriteItemViewModel = [FavoriteItemViewModel]()
        searchApi.fetch(query: query, page: 1) { status, movies, error in
            self.isLoading = false
            if let error = error {
                self.alertMessage = error.rawValue
            } else {
                self.processFavoriteViewModel(movies)
            }
        }
    }

    func getItemViewModel(at indexPath: IndexPath) -> FavoriteItemViewModel {
        favoriteItemViewModel[indexPath.row]
    }

    func removeAllSearchResult() {
        favoriteItemViewModel = [FavoriteItemViewModel]()
    }

    func favoriteMovieAction(at indexPath: IndexPath) {
        let movie = getItemViewModel(at: indexPath)

        if movie.isFavorite == true {
            // Unfavorite movie, deleted from core data
            deleteFavorite(movie.id) { status in
                self.favoriteItemViewModel[indexPath.row].isFavorite = false
                self.getData()
            }
        } else {
            // Favorited movie, store movie to core data
            var posterData = Data()
            
            Service.shared.downloadImage(url: URL(string: movie.posterUrl)!) {[weak self] data, error in
                DispatchQueue.main.async {
                    if error == nil, data != nil {
                        posterData = data!
                    }
                    self?.createFavorite(Int64(movie.id), movie.title, posterData)
                    self?.favoriteItemViewModel[indexPath.row].isFavorite = true
                    self?.favoriteItemViewModel[indexPath.row].posterData = posterData
                }
            }
        }
    }

    private func processFavoriteViewModel(_ movies:[FavoriteMovie]) {
        var tempItem = [FavoriteItemViewModel]()

        for movie in movies {
            tempItem.append(createFavoriteItemViewModel(movie: movie))
        }
        favoriteItemViewModel = tempItem
    }

    private func createFavoriteItemViewModel(movie: FavoriteMovie) -> FavoriteItemViewModel {
        var posterUrl = ""
        var isFav = false
        var posterData = Data()
        if !movie.posterPath.isEmpty {
            posterUrl = "https://image.tmdb.org/t/p/w185\(movie.posterPath)"
        }
        for local in localFavorite {
            if local.id == movie.id {
                isFav = true
                posterData = local.posterData
            }
        }

        return FavoriteItemViewModel(id: movie.id, title: movie.title, posterUrl: posterUrl, posterData: posterData, isFavorite: isFav)
    }


    //MARK: - Coredata
    func getFavorited(_ completion: @escaping(_ localFavorite: [FavoriteItemViewModel]) -> Void){
        var favoriteItems = [FavoriteItemViewModel]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")

        do{
            self.isLoading = false
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            result.forEach{ movie in
                favoriteItems.append(
                    FavoriteItemViewModel(id: movie.value(forKey: "id") as! Int, title: movie.value(forKey: "title") as! String, posterUrl: "", posterData: movie.value(forKey: "poster") as! Data, isFavorite: true)
                )
            }
            completion(favoriteItems)
        }catch let error {
            print(error.localizedDescription)
        }

    }

    private func createFavorite(_ id:Int64, _ title:String, _ poster:Data){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContext)
        let insert = NSManagedObject(entity: userEntity!, insertInto: managedContext)
        insert.setValue(id, forKey: "id")
        insert.setValue(title, forKey: "title")
        insert.setValue(poster, forKey: "poster")

        do{
            try managedContext.save()
        }catch let err{
            print(err)
        }

    }

    private func deleteFavorite(_ id:Int, completion: @escaping(_ status: Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Favorite")
        fetchRequest.predicate = NSPredicate(format: "id == \(id)")

        do{
            let dataToDelete = try managedContext.fetch(fetchRequest)[0] as! NSManagedObject
            managedContext.delete(dataToDelete)

            try managedContext.save()
            completion(true)
        }catch let err{
            print(err)
            completion(false)
        }

    }

}

struct FavoriteItemViewModel: FavoriteCollectionViewItemProtocol {
    var id: Int
    var title: String
    var posterUrl: String
    var posterData: Data
    var isFavorite: Bool
}
