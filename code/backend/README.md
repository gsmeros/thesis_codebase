# Movie Recommendation Backend

A FastAPI-based backend server for movie recommendations using TuriCreate machine learning models.

## Requirements

- Python 3.8 (required for TuriCreate compatibility)
- For Apple Silicon Macs: x86_64 architecture environment (Rosetta 2)

## Setup Instructions

### For Apple Silicon Macs (M1/M2/M3)

TuriCreate only supports x86_64 architecture, so you need to run Python under Rosetta 2:

```bash
# Download and install x86_64 miniconda
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o miniconda_x86.sh
arch -x86_64 bash miniconda_x86.sh -b -p $HOME/miniconda3_x86

# Accept terms of service
arch -x86_64 $HOME/miniconda3_x86/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
arch -x86_64 $HOME/miniconda3_x86/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create Python 3.8 environment
arch -x86_64 $HOME/miniconda3_x86/bin/conda create -n movie-rec python=3.8 -y

# Install requirements
arch -x86_64 bash -c "source $HOME/miniconda3_x86/bin/activate movie-rec && pip install -r requirements.txt"
```

### For Intel Macs or Linux

Simply use Python 3.8:
```bash
pip install -r requirements.txt
```

## Running the Server

### Apple Silicon Macs:
```bash
arch -x86_64 bash -c "source $HOME/miniconda3_x86/bin/activate movie-rec && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"
```

### Intel Macs/Linux:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API Endpoints

The server will be available at `http://localhost:8000` with the following endpoints:

- `GET /topRatedMovies` - Get top rated movies
- `GET /search?searchText={query}` - Search movies by title
- `GET /recommended` - Get personalized recommendations (requires auth token)
- `GET /getRatedMovies` - Get user's rated movies (requires auth token)
- `POST /rateMovie/{movie_id}/{rating}` - Rate a movie (requires auth token)
- `POST /login` - User authentication
- `POST /createAccount` - Create new user account
- `GET /restructureDatabase` - Database maintenance endpoint

## Configuration

The Firebase configuration is already set up in `main.py`. The TuriCreate model (`movie_rec`) is loaded automatically.
