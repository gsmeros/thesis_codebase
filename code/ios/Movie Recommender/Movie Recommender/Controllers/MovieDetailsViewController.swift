//
//  MovieDetailsViewController.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 11/01/2021.
//

import UIKit
import Kingfisher
import Alamofire

class MovieDetailsViewController: UIViewController {

    var movie: MovieData?
    
    private let omdb_apiKey = "7fcfe7d7"
    private let omdb_jsonBase = "https://www.omdbapi.com/"
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemOrange
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        setupUI()
        populateInitialData()
        fetchMovieDetails()
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel)
        contentView.addSubview(genreLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(indicator)
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // ScrollView fills the entire view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView matches scrollView width
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Poster image at top, full width, 1.5:1 aspect ratio
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            // Close button pinned to top-right of the view (not scrollView)
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Title below poster
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Tagline below title
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            taglineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taglineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Genre below tagline
            genreLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 12),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Release date below genre
            releaseDateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Overview below release date
            overviewLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Activity indicator centered on poster area
            indicator.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
        ])
    }
    
    private func populateInitialData() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title?.capitalized
        
        if let genres = movie.genres {
            genreLabel.text = genres
        }
        
        // Load poster immediately via OMDb (same proven approach as MovieCollectionViewCell)
        loadPosterFromOMDb(imdbId: movie.imdbId)
    }
    
    private func normalizedImdbId(_ imdbId: String?) -> String? {
        guard let raw = imdbId, !raw.isEmpty else { return nil }
        if raw.lowercased().hasPrefix("tt") { return raw }
        return "tt" + raw
    }
    
    private func loadPosterFromOMDb(imdbId: String?) {
        guard let imdb = normalizedImdbId(imdbId) else { return }
        
        AF.request(omdb_jsonBase, method: .get, parameters: ["i": imdb, "apikey": omdb_apiKey]).responseJSON { [weak self] response in
            guard let self = self else { return }
            if let obj = response.value as? [String: Any],
               let poster = obj["Poster"] as? String,
               poster != "N/A",
               let url = URL(string: poster) {
                DispatchQueue.main.async {
                    self.posterImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "placeholder"),
                        options: [.transition(.fade(0.2)), .cacheOriginalImage]
                    )
                }
            }
        }
    }
    
    private func fetchMovieDetails() {
        guard let tmdbId = movie?.tmdbId else {
            indicator.stopAnimating()
            return
        }
        
        indicator.startAnimating()
        
        MovieHandler.shared.getMovieDetails(tmdbId: tmdbId) { [weak self] (tagline, overview, genres, releaseDate, posterPath) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.indicator.stopAnimating()
                
                if let tagline = tagline, !tagline.isEmpty {
                    self.taglineLabel.text = "\"\(tagline)\""
                }
                
                if let overview = overview, !overview.isEmpty {
                    self.overviewLabel.text = overview
                }
                
                // Prefer TMDB genres over the pipe-separated backend genres
                if let genres = genres, !genres.isEmpty {
                    self.genreLabel.text = genres
                }
                
                if let releaseDate = releaseDate, !releaseDate.isEmpty {
                    self.releaseDateLabel.text = "Release: \(releaseDate)"
                }
                
                // Upgrade to higher-res TMDB poster if available
                if let posterPath = posterPath, let url = URL(string: posterPath) {
                    self.posterImageView.kf.setImage(
                        with: url,
                        placeholder: self.posterImageView.image,
                        options: [.transition(.fade(0.3)), .cacheOriginalImage]
                    )
                }
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
