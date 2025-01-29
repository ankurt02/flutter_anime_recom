from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import pickle
from sklearn.neighbors import NearestNeighbors
from sklearn.metrics import precision_score, recall_score, f1_score, mean_absolute_error

app = Flask(__name__)
CORS(app)

# Load the model and dataset
with open("model.pkl", "rb") as f:
    knn = pickle.load(f)

df = pd.read_csv("../dataset/anime.csv")

# Load the preprocessed features_combined
features_combined = np.load('..\\code\\features_combined.npy')  # Load the features_combined matrix

def get_index_from_title(title):
    try:
        return df[df['Name'].str.lower() == title.lower()].index[0]
    except IndexError:
        return -1  # Return -1 if the title is not found

def recommend_anime_knn(title, top_n=10):
    anime_index = get_index_from_title(title)
    if anime_index == -1:
        return {"error": "Anime not found"}

    distances, indices = knn.kneighbors(features_combined[anime_index].reshape(1, -1))
    
    # Get the names, ratings, and episodes of the recommended anime
    # Ensure the 'Rating Score' and 'Episodes' are treated as the correct types
    recommended_anime = df.iloc[indices[0][1:top_n+1]][['Name', 'Rating Score', 'Episodes']]

# Ensure 'Rating Score' is numeric (float) and 'Episodes' is integer
    recommended_anime['Rating Score'] = pd.to_numeric(recommended_anime['Rating Score'], errors='coerce')
    recommended_anime['Episodes'] = pd.to_numeric(recommended_anime['Episodes'], errors='coerce')

# Convert DataFrame to list of dictionaries and ensure proper data types
    anime_list = recommended_anime.to_dict(orient='records')

# Send the proper response with Rating Score and Episodes in the correct format
    return anime_list



@app.route("/recommend", methods=["POST"])
def recommend():
    data = request.json
    title = data.get("title")
    
    if not title:
        return jsonify({"error": "Anime title is required"}), 400
    
    recommendations = recommend_anime_knn(title)
    print("length : ",len(recommendations))
    return jsonify({"recommendations": recommendations})  # Convert numpy array to list

@app.route("/metrics", methods=["POST"])
def evaluate():
    data = request.json
    anime_liked = data.get("anime_liked")
    
    if not anime_liked:
        return jsonify({"error": "Anime title is required for evaluation"}), 400
    
    recommended_anime_knn = recommend_anime_knn(anime_liked)
    
    if "error" in recommended_anime_knn:
        return jsonify(recommended_anime_knn), 400
    
    # Get the recommended indices
    recommended_indices = [get_index_from_title(anime) for anime in recommended_anime_knn]
    pred_labels = np.zeros(len(df))
    pred_labels[recommended_indices] = 1

    # Similarity threshold for true positives
    distances, _ = knn.kneighbors(features_combined)
    similarity_threshold = np.percentile(distances.flatten(), 90)  # Top 10% most similar as true positives
    _, indices = knn.kneighbors(features_combined[get_index_from_title(anime_liked)].reshape(1, -1))
    true_labels = np.zeros(len(df))
    true_labels[indices[0][1:]] = 1

    precision = precision_score(true_labels, pred_labels)
    recall = recall_score(true_labels, pred_labels)
    f1 = f1_score(true_labels, pred_labels)

    df['Rating Score'] = pd.to_numeric(df['Rating Score'].replace('Unknown', np.nan), errors='coerce')
    df['Rating Score'] = df['Rating Score'].fillna(df['Rating Score'].mean())

    true_ratings = df['Rating Score'].values
    pred_ratings = np.zeros(len(df))
    pred_ratings[recommended_indices] = df.loc[get_index_from_title(anime_liked), 'Rating Score']
    mae = mean_absolute_error(true_ratings, pred_ratings)

    metrics = {
        "Precision": round(precision, 3),
        "Recall": round(recall, 3),
        "F1 Score": round(f1, 3),
        "Mean Absolute Error": round(mae, 3)
    }

    return jsonify(metrics)

if __name__ == "__main__":
    app.run(debug=True)
