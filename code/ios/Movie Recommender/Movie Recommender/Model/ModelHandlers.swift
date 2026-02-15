//
//  MovieModel.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 08/01/2021.
//

import Foundation
import Alamofire


class MovieDataBaseStructure: Codable {
    var movies: [MovieData]?
    private enum CodingKeys : String, CodingKey {
        case movies = "Movies"
    }
}

class MovieData: NSObject, Codable {

    var movieId: Int?
    var title: String?
    var tmdbId: String?
    var imdbId: String?
    var ratings: [Double]?
    var genres: String?
    var rating: Double?
    var movieDescription: String?
    var genreDescription: String?
    
    private enum CodingKeys : String, CodingKey {
        case movieId = "movieid"
        case title = "title"
        case tmdbId = "tmdbid"
        case imdbId = "imdbid"
        case ratings = "ratings"
        case rating = "rating"
        case genres = "genres"
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            movieId = try? values.decode(Int.self, forKey: .movieId)
            title = try? values.decode(String.self, forKey: .title)
            tmdbId = try? values.decode(String.self, forKey: .tmdbId)
            imdbId = try? values.decodeIfPresent(String.self, forKey: .imdbId)
            ratings = try? values.decodeIfPresent([Double].self, forKey: .ratings)
            rating = try? values.decodeIfPresent(Double.self, forKey: .rating)
            genres = try? values.decodeIfPresent(String.self, forKey: .genres)
            
            if tmdbId == nil {
                let intValue = try? values.decode(Int.self, forKey: .tmdbId)
                if let value = intValue {
                    tmdbId = String(value)
                }
            }
            if imdbId == nil {
                let intValue = try? values.decode(Int.self, forKey: .imdbId)
                if let value = intValue {
                    imdbId = String(value)
                }
            }
        } catch {
            print(error)
        }
    }

}

class UserHandler {
    var baseURL = "http://127.0.0.1:8000/"
    static let shared = UserHandler()
    var userToken: String?
    var username: String?
    func isLoggedIn() -> Bool {
        return userToken != nil
    }
    
    func logOut() {
        UserHandler.shared.userToken = nil
        UserHandler.shared.username = nil
    }
    
    func logIn(username: String, password: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers: HTTPHeaders = HTTPHeaders.init([HTTPHeader.init(name: "username", value: username), HTTPHeader.init(name: "password", value: password)])
        AF.request(baseURL + "login", method: .post, headers: headers).responseJSON { (response) in
            guard let json = response.value as? [String: Any] else {
                completionHandler(false, "Something went wrong. Please try again.")
                return
            }
            
            guard let user = json["User"] as? [String: Any], let token = user["idToken"] as? String else {
                completionHandler(false, (json["Message"] as? String) ?? "Something went wrong. Please try again.")
                return
            }
            UserHandler.shared.username = username
            UserHandler.shared.userToken = token
            completionHandler(true, nil)
        }
    }
    
    func createAccount(username: String, password: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers: HTTPHeaders = HTTPHeaders.init([HTTPHeader.init(name: "username", value: username), HTTPHeader.init(name: "password", value: password)])
        AF.request(baseURL + "createAccount", method: .post, headers: headers).responseJSON { (response) in
            guard let json = response.value as? [String: Any] else {
                completionHandler(false, "Something went wrong. Please try again.")
                return
            }
            
            guard let resultString = json["Result"] as? String, resultString == "success" else {
                completionHandler(false, (json["Message"] as? String) ?? "Something went wrong. Please try again.")
                return
            }
            completionHandler(true, nil)
        }
    }
}

class MovieHandler {
    
    static let shared = MovieHandler()
    var data: [MovieData] = []
    var baseURL = "http://127.0.0.1:8000/"
    let tmdbApiKey = "943b7b1cc3ad5ab0d825bd6befe5cf82"
    let baseImagePath = "https://image.tmdb.org/t/p/w180"
    let tmdbBaseURL = "https://api.themoviedb.org/3/movie/"
    
    private func movieWith(movieId: Int) -> MovieData? {
        for movie in data {
            if let id = movie.movieId, id == movieId {
                return movie
            }
        }
        return nil
    }
    
    private func movieWith(tmdbId: String) -> MovieData? {
        for movie in data {
            if let id = movie.tmdbId, id == tmdbId {
                return movie
            }
        }
        return nil
    }
    
    func getTopRatedMovies(completionHandler: @escaping ([MovieData]?) -> Void) {
        AF.request(baseURL + "topRatedMovies", method: .get).responseJSON { (response) in
            guard let data = response.data else {
                completionHandler(nil)
                return
            }
            print(response.value)
            do {
                let decoder = JSONDecoder()
                let decodedMovieStructure = try decoder.decode(MovieDataBaseStructure.self, from: data)
                completionHandler(decodedMovieStructure.movies ?? [])
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    func searchMovies(searchText: String?, completionHandler: @escaping ([MovieData]?) -> Void) {
        AF.request(baseURL + "search", method: .get, parameters: ["searchText": searchText?.lowercased()]).responseJSON { (response) in
            guard let data = response.data else {
                completionHandler(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedMovieStructure = try decoder.decode(MovieDataBaseStructure.self, from: data)
                completionHandler(decodedMovieStructure.movies ?? [])
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    func getRecommended(completionHandler: @escaping ([MovieData]?) -> Void) {
        let headers: HTTPHeaders = HTTPHeaders.init([HTTPHeader.init(name: "userToken", value: UserHandler.shared.userToken!), HTTPHeader.init(name: "username", value: UserHandler.shared.username!)])
        AF.request(baseURL + "recommended", method: .get, headers: headers).responseJSON { (response) in
            guard let data = response.data else {
                completionHandler(nil)
                return
            }
            print(response.value)
            do {
                let decoder = JSONDecoder()
                let decodedMovieStructure = try decoder.decode(MovieDataBaseStructure.self, from: data)
                completionHandler(decodedMovieStructure.movies ?? [])
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    func getRatedMovies(completionHandler: @escaping ([MovieData]?) -> Void) {
        let headers: HTTPHeaders = HTTPHeaders.init([HTTPHeader.init(name: "userToken", value: UserHandler.shared.userToken!), HTTPHeader.init(name: "username", value: UserHandler.shared.username!)])
        AF.request(baseURL + "getRatedMovies", method: .get, headers: headers).responseJSON { (response) in
            guard let data = response.data else {
                completionHandler(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedMovieStructure = try decoder.decode(MovieDataBaseStructure.self, from: data)
                completionHandler(decodedMovieStructure.movies ?? [])
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    func recommend(_ movieId: Int, rating: Int, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers: HTTPHeaders = HTTPHeaders.init([HTTPHeader.init(name: "userToken", value: UserHandler.shared.userToken!), HTTPHeader.init(name: "username", value: UserHandler.shared.username!)])
        AF.request(baseURL + "rateMovie/\(movieId)/\(rating)", method: .post, headers: headers).responseJSON { (response) in
            guard let json = response.value as? [String: Any] else {
                completionHandler(false, "Something went wrong, please try again.")
                return
            }
            guard let result = json["Result"] as? String, result == "success" else {
                completionHandler(false, (json["Message"] as? String) ?? "Something went wrong, please try again.")
                return
            }
            completionHandler(true, nil)
        }
    }
    
    func getMovieDetails(tmdbId: String, completionHandler: @escaping (String?, String?, String?, String?, String?) -> Void) {
        let url = tmdbBaseURL + tmdbId
        AF.request(url, method: .get, parameters: ["api_key": tmdbApiKey]).responseJSON { (response) in
            guard let json = response.value as? [String: Any] else {
                completionHandler(nil, nil, nil, nil, nil)
                return
            }
            let tagline = json["tagline"] as? String
            let overview = json["overview"] as? String
            let releaseDate = json["release_date"] as? String
            let posterPath = json["poster_path"] as? String
            
            var genreNames: String?
            if let genres = json["genres"] as? [[String: Any]] {
                let names = genres.compactMap { $0["name"] as? String }
                genreNames = names.joined(separator: ", ")
            }
            
            let fullPosterPath: String? = posterPath != nil ? "https://image.tmdb.org/t/p/w500" + posterPath! : nil
            
            completionHandler(tagline, overview, genreNames, releaseDate, fullPosterPath)
        }
    }
    
//    func searchForMovieWith(title: String, k: Int = 10) -> [MovieData] {
//        var title_distance = [(Double, Int)]()
//        for (index, value) in data["title"]!.enumerated() {
//            title_distance.append((Double(title.lowercased().distance(to: (value as! String).lowercased())), index))
//            if (value as! String).lowercased().contains(title.lowercased()) {
//                title_distance[title_distance.count-1].0 = title_distance.last!.0 / 4
//            }
//        }
//        title_distance.sort(by: {$0.0 < $1.0})
//        var movies = [MovieData]()
//        for i in 0..<k {
//            movies.append(movieWith(index: title_distance[i].1)!)
//        }
//        return movies
//    }
}
