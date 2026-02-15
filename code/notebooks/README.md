# Notebooks (TuriCreate)

- Requirements: `turicreate`, `pandas`

Typical flow:
1. Open `movie_recommendation_training.ipynb` in Jupyter.
2. Load `ratings.csv` from MovieLens, drop `timestamp`.
3. Train item-similarity model (`tc.item_similarity_recommender.create`).
4. Save artifact folder `movie_recommendation_model/`.

Outputs (not committed):
- `movie_recommendation_model/` (folder)
- Any large CSVs or derived splits
