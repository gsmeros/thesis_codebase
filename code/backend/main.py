from typing import Optional
import pyrebase
from pydantic import BaseModel, HttpUrl
from typing import List
from typing import Dict
from typing import Optional
from fastapi.encoders import jsonable_encoder
import json
import turicreate as tc
from fastapi import FastAPI, Header, Form
# Temporarily replace quote function
def noquote(s):
    return s
pyrebase.pyrebase.quote = noquote

model = tc.load_model("movie_rec")

app = FastAPI()

class Movie(BaseModel):
    title: Optional[str]
    imdbid: Optional[str]
    tmdbid: Optional[str]
    movieid: Optional[int]
    ratings: Optional[List[float]]
    rating: Optional[float]

tmdbApiKey = "943b7b1cc3ad5ab0d825bd6befe5cf82"
baseImagePath = "https://image.tmdb.org/t/p/w500"
tmdbBaseURL = "https://api.themoviedb.org/3/movie/"

config = {
  "apiKey": "AIzaSyCN4Y0a7l9IuKa1Qav_SnARadYJO3lSPAs",
  "authDomain": "movie-recommendations-d153b.firebaseapp.com",
  "databaseURL": "https://movie-recommendations-d153b.firebaseio.com/",
  "storageBucket": "projectId.appspot.com"
}


firebase = pyrebase.initialize_app(config)
auth = firebase.auth()
db = firebase.database()


@app.get("/restructureDatabase")
def read_root():
    links = db.child("links").order_by_child("movieid").get()
    for link in links:
        movieid: int = link.val()["movieid"]
        imdbid: str = link.val()["imdbid"]
        tmdbid: int = link.val()["tmdbid"]
        movies = db.child("movies").order_by_child("movieid").equal_to(movieid).get()
        for movie in movies:
            title: str = movie.val()["title"]
            genre: str = movie.val()["genres"]
            data = {
                "movieid": movieid,
                "imdbid": imdbid,
                "tmdbid": tmdbid,
                "title": title,
                "genres": genre
            }
            db.child("movies").child(movie.key()).update(data)
    return {"complete": "true"}


@app.get("/topRatedMovies")
def read_root(userToken: Optional[str] = Header(None)):
    ratings = db.child("ratings").order_by_child("rating").limit_to_last(2500).get()
    moviesDB: Dict[int, List[float]] = {}
    for rating in ratings.each():
        movieId: int = rating.val()['movieid']
        ratingValue: float = rating.val()['rating']
        if movieId in list(moviesDB.keys()):
            currentRatings: List[float] = moviesDB[movieId]
            currentRatings.append(ratingValue)
            moviesDB[movieId] = currentRatings
        else:
            newList: List[float] = [ratingValue]
            moviesDB[movieId] = newList

    finalMovies: List[Movie] = []
    totalMovies = db.child("movies").get().val()
    
    for movieid in moviesDB:
        movieRatings: List[float] = moviesDB[movieid]
        movieWithID: tuple = tuple()
        for movie in totalMovies:
             if movie["movieid"] == movieid:
                movieWithID = movie
                break
        movieTitle: Optional[str] = movieWithID["title"]
        imdbid: Optional[str] = str(movieWithID["imdbid"]) if movieWithID["imdbid"] is not None else None
        tmdbid: Optional[str] = str(movieWithID["tmdbid"]) if movieWithID["tmdbid"] is not None else None
        # Calculate average rating for this movie
        avgRating: float = sum(movieRatings) / len(movieRatings) if movieRatings else 0.0
        finalMovie: Movie = Movie(title = movieTitle, movieid = movieid, imdbid = imdbid, tmdbid = tmdbid, ratings = movieRatings, rating = avgRating)
        finalMovies.append(finalMovie)

    return {"Movies": finalMovies}


@app.get("/search")
def read_root(searchText: Optional[str]):
    movies = db.child("movies").order_by_child("title").start_at(searchText).end_at(searchText+"\uf8ff").get()

    finalMovies: List[Movie] = []
    for movie in movies.each():
        movieid: int = movie.val()['movieid']
        imdbid: Optional[str] = str(movie.val()["imdbid"]) if movie.val()["imdbid"] is not None else None
        tmdbid: Optional[str] = str(movie.val()["tmdbid"]) if movie.val()["tmdbid"] is not None else None
        finalMovie: Movie = Movie(title = movie.val()["title"], movieid = movieid, imdbid = imdbid, tmdbid = tmdbid, ratings = None, rating = None)
        finalMovies.append(finalMovie)
    return {"Movies": finalMovies}


@app.get("/recommended")
def read_root(userToken: Optional[str] = Header(None)):
    try:
        #validate user token
        user = auth.get_account_info(userToken)
        localId = user['users'][0]['localId']
        #get rated movies from list of ratings, for user with local id
        ratings = db.child("ratings").order_by_child("userid").equal_to(localId).get()

        movieIdList: [int] = []
        ratingList: [float] = []
        for rating in ratings.each():
            movieid: int = rating.val()["movieid"]
            rating: float = rating.val()["rating"]
            movieIdList.append(movieid)
            ratingList.append(rating)

        user_preferences = tc.SFrame({"movieId": movieIdList, "ratings": ratingList})
        recommendations = model.recommend_from_interactions(user_preferences)
        print(recommendations)
        
        totalMovies = db.child("movies").get().val()
        recommendedMovies: [tuple] = []
        for recId in list(recommendations["movieId"]):
            for movie in totalMovies:
                if movie["movieid"] == recId:
                    recommendedMovies.append(movie)
                    break
        print(recommendedMovies)
        return {"Movies": recommendedMovies}
        # return json.dumps({"movieId": list(recommendations["movieId"]), "score": list(recommendations["score"])})
    except Exception as e:
        print(e)
        return {"Error": e}


@app.get("/getRatedMovies")
async def ratedMovies(userToken: Optional[str] = Header(None), username: Optional[str] = Header(None)):
    try:
        user = auth.get_account_info(userToken)
        localId = user['users'][0]['localId']
        ratings = db.child("ratings").order_by_child("userid").equal_to(localId).get()
        restructuredMovies: List[Movie] = []
        totalMovies = db.child("movies").get().val()

        for rating in ratings.each():
            movieid: int = rating.val()["movieid"]
            movieWithID: tuple = tuple()
            for movie in totalMovies:
                if movie["movieid"] == movieid:
                    movieWithID = movie
                    break
            imdbid: Optional[str] = str(movie["imdbid"]) if movie["imdbid"] is not None else None
            tmdbid: Optional[str] = str(movie["tmdbid"]) if movie["tmdbid"] is not None else None
            title: Optional[str] = movie["title"]
            ratingValue: Optional[float] = rating.val()["rating"]

            restructuredMovie = Movie(title = title, movieid = movieid, imdbid = imdbid, tmdbid = tmdbid, rating = ratingValue, ratings = None)
            restructuredMovies.append(restructuredMovie)
        return {"Movies": restructuredMovies}
    except Exception as e:
        print(e)
        return {"Message": e}


@app.post("/rateMovie/{movie_id}/{rating}")
def rateMovie(movie_id: int, rating: int, userToken: Optional[str] = Header(None)):
    try:
        #validate user token
        user = auth.get_account_info(userToken)
        userArray: List[json] = user["users"]
        localId = user['users'][0]['localId']
        ratingKey = localId+str(movie_id)
        data = {
            "userid": localId,
            "movieid": movie_id,
            "rating": rating
         }
        db.child("ratings").child(ratingKey).remove()
        db.child("ratings").child(ratingKey).set(data)
        return {"Result": "success"} 
    except Exception as e:
        print(e)
        return {"Message": e}


@app.post("/login")
async def login(username: str = Header(None), password: str = Header(None)):
    try:
        user = auth.sign_in_with_email_and_password(username, password)
        return{"User": user}
    except Exception as e:
       print(json.loads(e.args[1])['error']['message'])
       return {"Message": json.loads(e.args[1])['error']['message']}



@app.post("/createAccount")
async def createAccount(username: str = Header(None), password: str = Header(None)):
    try:
        user = auth.create_user_with_email_and_password(username, password)
        return {"Result": "success"}
    except Exception as e:
       return {"Message": json.loads(e.args[1])['error']['message']}