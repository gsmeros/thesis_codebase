//
//  RatingsView.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 08/01/2021.
//

import Foundation
import UIKit

protocol RatingDelegate: class {
    func ratingChanged(movieId: Int, rating: Int)
}

class RatingsView: UIView {
    
    @IBOutlet var contentView: UIView!
    weak var delegate: RatingDelegate?
    var movie: MovieData?
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RatingsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        [self.star1, self.star2, self.star3, self.star4, self.star5].forEach({
            $0?.tintColor = .orange
            $0?.imageView?.contentMode = .scaleToFill
        })
    }
    
    func animateStar(index: Int) {
        UIView.animate(withDuration: 0.6,
                       animations: {
                        switch index {
                        case 1: self.star1.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        case 2: self.star2.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        case 3: self.star3.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        case 4: self.star4.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        case 5: self.star5.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        default: break
                        }
                        
                       },
                       completion: { _ in
                        UIView.animate(withDuration: 0.25) {
                            switch index {
                            case 1: self.star1.transform = CGAffineTransform.identity
                            case 2: self.star2.transform = CGAffineTransform.identity
                            case 3: self.star3.transform = CGAffineTransform.identity
                            case 4: self.star4.transform = CGAffineTransform.identity
                            case 5: self.star5.transform = CGAffineTransform.identity
                            default: break
                            }
                        }
                       })
    }
    
    func resetUI() {
        [self.star1, self.star2, self.star3, self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
    }
    
    func setUITo1() {
        [self.star2, self.star3, self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
        [self.star1].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
    }
    @IBAction func star1Pressed(_ sender: Any) {
        self.setUITo1()
        guard let movie = self.movie, let movieId = movie.movieId else {return}
        self.animateStar(index: 1)
        self.delegate?.ratingChanged(movieId: movieId, rating: 1)
    }
    
    func setUITo2() {
        [self.star3, self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
        [self.star1, self.star2].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
    }
    @IBAction func star2Pressed(_ sender: Any) {
        self.setUITo2()
        guard let movie = self.movie, let movieId = movie.movieId else {return}
        self.animateStar(index: 2)
        self.delegate?.ratingChanged(movieId: movieId, rating: 2)
    }
    
    func setUITo3() {
        [self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
        [self.star1, self.star2, self.star3].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
    }
    @IBAction func star3Pressed(_ sender: Any) {
        self.setUITo3()
        guard let movie = self.movie, let movieId = movie.movieId else {return}
        self.animateStar(index: 3)
        self.delegate?.ratingChanged(movieId: movieId, rating: 3)
    }
    func setUITo4() {
        [self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
        [self.star1, self.star2, self.star3, self.star4].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
    }
    @IBAction func star4Pressed(_ sender: Any) {
        [self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star"), for: .normal)
        })
        [self.star1, self.star2, self.star3, self.star4].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
        guard let movie = self.movie, let movieId = movie.movieId else {return}
        self.animateStar(index: 4)
        self.delegate?.ratingChanged(movieId: movieId, rating: 4)
    }
    
    func setUITo5() {
        [self.star1, self.star2, self.star3, self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
    }
    @IBAction func star5Pressed(_ sender: Any) {
        [self.star1, self.star2, self.star3, self.star4, self.star5].forEach({
            $0.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        })
        guard let movie = self.movie, let movieId = movie.movieId else {return}
        self.animateStar(index: 5)
        self.delegate?.ratingChanged(movieId: movieId, rating: 5)
    }
}
