# Movie Recommender — Diploma Thesis

**Υλοποίηση εφαρμογής για iPhone που προτείνει ταινίες στο χρήστη χρησιμοποιώντας αλγόριθμους μηχανικής μάθησης**

Georgios Smeros — University of Patras, ECE Department, 2025

## Structure

```
code/
├── ios/                  # iOS app (Swift, UIKit, Storyboards)
├── backend/              # FastAPI server (Python 3.8)
├── notebooks/            # TuriCreate model training (Jupyter)
├── data-scripts/         # Dataset import utilities
└── assets/
    ├── architecture/     # Mermaid diagrams (.mmd)
    ├── ml-latest-small/  # MovieLens dataset (CSV)
    └── screenshots/      # App screenshots
```

## Quick Start

### 1. Backend

Requires Miniconda x86_64 (Rosetta 2 on Apple Silicon).

```bash
conda create -n movie_rec python=3.8
conda activate movie_rec
pip install turicreate==6.4 fastapi==0.104.0 pyrebase4==4.7.1 uvicorn==0.24.0 pandas==2.0.3 numpy==1.24.3
cd backend
uvicorn main:app --reload
```

Server runs at `http://localhost:8000`.

### 2. iOS App

Requires Xcode 16+ and CocoaPods.

```bash
cd ios/Movie\ Recommender
pod install
open Movie\ Recommender.xcworkspace
```

Set the backend URL in the app to your local IP (e.g. `http://192.168.1.x:8000`).
Minimum deployment target: iOS 13.0.

### 3. Model Training

```bash
cd notebooks
jupyter notebook movie_recommendation_training.ipynb
```

Training takes ~6 seconds. Output saved to `backend/movie_rec/`.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Swift, UIKit, Storyboards, CocoaPods |
| Backend | Python 3.8, FastAPI, Uvicorn |
| ML Model | TuriCreate 6.4 (item-based CF) |
| Database | Firebase Realtime Database + Auth |
| Movie Data | TMDB API |
| Dependencies (iOS) | Alamofire 5.4, Kingfisher 6.0 |
| Dependencies (Python) | Pyrebase4, Pandas, NumPy |
| Dataset | MovieLens ml-latest-small (100,836 ratings) |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/login` | Firebase Auth login |
| POST | `/createAccount` | Register new user |
| GET | `/topRatedMovies` | Movies with ratings |
| GET | `/search?searchText=...` | Search by title prefix |
| GET | `/recommended` | Personalized recommendations |
| GET | `/getRatedMovies` | User's rated movies |
| POST | `/rateMovie/{id}/{rating}` | Submit/update rating |
| GET | `/restructureDatabase` | One-time data import |

## License

© 2025 Georgios Smeros — All rights reserved.
