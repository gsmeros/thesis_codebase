//
//  MovieCollectionViewCell.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 08/01/2021.
//

import UIKit
import Kingfisher
import Alamofire

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingsView: RatingsView!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var scrimView: UIView!
    
    private var currentImdbId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artwork.clipsToBounds = true
        artwork.layer.cornerRadius = 10
        artwork.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMinYCorner]
        ratingsView.clipsToBounds = true
        ratingsView.layer.cornerRadius = 10
        ratingsView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        scrimView.clipsToBounds = true
        scrimView.layer.cornerRadius = 10
        scrimView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImdbId = nil
        artwork.kf.cancelDownloadTask()
        artwork.image = UIImage(named: "placeholder")
        ratingsView.resetUI()
        titleLabel.text = nil
    }
   
    let omdb_apiKey = "7fcfe7d7"
    let omdb_jsonBase = "https://www.omdbapi.com/"
    
    func setMovieDetails(movie: MovieData) {
        self.titleLabel.text = movie.title?.capitalized
        self.ratingsView.movie = movie
        if let rating = movie.rating {
            switch Int(rating) {
            case 1:
                self.ratingsView.setUITo1()
            case 2:
                self.ratingsView.setUITo2()
            case 3:
                self.ratingsView.setUITo3()
            case 4:
                self.ratingsView.setUITo4()
            case 5:
                self.ratingsView.setUITo5()
            default:
                self.ratingsView.resetUI()
            }
        } else {
            self.ratingsView.resetUI()
        }
        artwork.image = UIImage(named: "placeholder")
        currentImdbId = movie.imdbId
        self.loadCover(movieIMDBid: movie.imdbId)
    }
    
    private func normalizedImdbId(_ imdbId: String?) -> String? {
        guard let raw = imdbId, !raw.isEmpty else { return nil }
        if raw.lowercased().hasPrefix("tt") { return raw }
        return "tt" + raw
    }
    
    func loadCover(movieIMDBid: String?) {
        guard let imdb = normalizedImdbId(movieIMDBid) else {
            self.artwork.image = UIImage(named: "placeholder")
            return
        }
        // Ensure we're still displaying same item
        guard self.currentImdbId == movieIMDBid else { return }
        
        // OMDb JSON endpoint: https://www.omdbapi.com/?i=ttXXXXXXX&apikey=KEY
        AF.request(omdb_jsonBase, method: .get, parameters: ["i": imdb, "apikey": omdb_apiKey]).responseJSON { [weak self] response in
            guard let self = self else { return }
            guard self.currentImdbId == movieIMDBid else { return }
            if let obj = response.value as? [String: Any],
               let poster = obj["Poster"] as? String,
               poster != "N/A",
               let url = URL(string: poster) {
                print("OMDb JSON Poster URL: \(poster)")
                self.artwork.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholder"),
                    options: [.transition(.fade(0.2)), .cacheOriginalImage]
                )
            } else {
                self.artwork.image = UIImage(named: "placeholder")
            }
        }
    }
}
