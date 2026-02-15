//
//  RecommendationsViewController.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 11/01/2021.
//

import UIKit

class RecommendationsViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    var recommendedMovies: [MovieData] = []
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        self.updateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCollectionViewCell")
        self.indicator.color = .darkGray
        self.updateData()
    }
    
    func updateData() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
        MovieHandler.shared.getRecommended { (movies) in
            DispatchQueue.main.async {
                self.recommendedMovies = movies ?? []
                self.collectionView.reloadData()
                self.indicator.stopAnimating()
            }
        }
    }
}

extension RecommendationsViewController: RatingDelegate {
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

extension RecommendationsViewController: UICollectionViewDelegateFlowLayout {
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

extension RecommendationsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell {
            let movie = self.recommendedMovies[indexPath.row]
            cell.setMovieDetails(movie: movie)
            cell.ratingsView.delegate = self
            return cell
        } else {
            return MovieCollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.recommendedMovies[indexPath.row]
        let detailsVC = MovieDetailsViewController()
        detailsVC.movie = movie
        detailsVC.modalPresentationStyle = .pageSheet
        self.present(detailsVC, animated: true, completion: nil)
    }
}
