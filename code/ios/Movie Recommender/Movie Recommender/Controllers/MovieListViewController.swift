//
//  MovieListViewController.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 08/01/2021.
//

import UIKit
extension MovieListViewController: UISearchBarDelegate {
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {return}
        
        guard !searchText.isEmpty else {
            self.searchData = self.topRated
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return
        }
        
        self.searchData = []
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.indicator.startAnimating()
        }
        
        MovieHandler.shared.searchMovies(searchText: searchText) { (movies) in
            DispatchQueue.main.async {
                if let filteredMovies = movies {
                    self.searchData = searchText.isEmpty ? self.topRated : filteredMovies
                    self.collectionView.reloadData()
                }
                self.indicator.stopAnimating()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchData = topRated
        searchBar.endEditing(true)
        collectionView.reloadData()
    }
    
    @objc func dismissSearchBar() {
        self.view.endEditing(false)
    }
    
    func createToolBarForBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissSearchBar))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.tintColor = UIColor.black
        doneButton.tintColor = UIColor.black
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                toolBar.tintColor = UIColor.white
                doneButton.tintColor = UIColor.white
                doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            }
        }
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
}

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var searchData: [MovieData] = []
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var topRated: [MovieData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.inputAccessoryView = self.createToolBarForBar()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCollectionViewCell")
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        self.indicator.color = .darkGray
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
        MovieHandler.shared.getTopRatedMovies { (movies) in
            DispatchQueue.main.async {
                if let movies = movies {
                    let sortedMovies = movies.sorted(by: { (first, second) -> Bool in
                        let firstTotalSum: Double = (first.ratings ?? []).compactMap({$0}).reduce(0, +)
                        let firstCount: Int = (first.ratings ?? [1]).count
                        let firstAverage = firstTotalSum/Double(firstCount)
                        
                        let secondTotalSum: Double = (second.ratings ?? []).compactMap({$0}).reduce(0, +)
                        let secondCount: Int = (second.ratings ?? [1]).count
                        let secondAverage = secondTotalSum/Double(secondCount)
                        
                        if firstAverage == secondAverage {
                            return firstCount > secondCount
                        } else {
                            return firstAverage > secondAverage
                        }
                    })
                    self.searchData = sortedMovies
                    self.topRated = sortedMovies
                    self.collectionView.reloadData()
                }
                self.indicator.stopAnimating()
            }
        }
    }
}

extension MovieListViewController: RatingDelegate {
    func ratingChanged(movieId: Int, rating: Int) {
        MovieHandler.shared.recommend(movieId, rating: rating) { (success, errorMessage) in
            if success {
                //do nothing
            } else {
                //inform user of error
                let alertVC = UIAlertController.init(title: "Error", message: errorMessage ?? "Something went wrong", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
}

extension MovieListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10)/2.0
        let height = collectionView.frame.height/2.2
        let size = CGSize.init(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell {
            let movie = self.searchData[indexPath.row]
            cell.setMovieDetails(movie: movie)
            cell.ratingsView.delegate = self
            return cell
        } else {
            return MovieCollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.searchData[indexPath.row]
        let detailsVC = MovieDetailsViewController()
        detailsVC.movie = movie
        detailsVC.modalPresentationStyle = .pageSheet
        self.present(detailsVC, animated: true, completion: nil)
    }
}
