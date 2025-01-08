# Anime Recommendation using KNN, made with Flutter :blue_heart:

This project is a flutter application integrated with machine learning model to recommend anime based on the user input.
The model used is K-Nearest Neighbors (KNN) algorithm, to recommend the most relevant anime.

The application is built with Flutter and uses the following libraries:
### Python libraries:
* numpy
* pandas
* sklearn
* seaborn
* matplotlib

### Flutter libraries:
* http
* device_preview

There are several algorithms used to recommend simiar animes, such as KNN, K-Means, Cosine Similarity and Eculidean distance.

But for the final recommendation, KNN is used.



<br>
<br>

## How to run the app

clone the repository:
```
git clone https://github.com/ankurt02/flutter_anime_recom.git
```


open the project folder

add the required dependancies to pubspec.yaml
```
flutter pub get
```


download required python libraries
```
pip install -r requirements.txt
```


### run the python-flask server
navigate to anime_rec -> backend -> model
```
cd backend\model
```



run the following command to start the server
```
python app.py
```



open new terminal, CMD
run the flutter app using
```
flutter run
```


<br>
<br>


## Screenshots
<div style="display: flex; justify-content: space-between; margin: 6px;">
    <div style="text-align: center; width: 300px;">
        <img src="screenshots\naruto_recom.png" alt="Anime recommendation for Naruto" style="width: 100%; height: 550px; margin: 6px;" />
        <figcaption style="background-color: #0f0f0f; color: white; font-style: italic; padding: 2px;">
            Fig. - Anime recommendation for Naruto.
        </figcaption>
    </div>
    <div style="text-align: center; width: 300px;">
        <img src="screenshots\one_piece_recom.png" alt="Anime recommendation for One-Piece" style="width: 100%; height: 550px; margin: 6px;" />
        <figcaption style="background-color: #0f0f0f; color: white; font-style: italic; padding: 2px;">
            Fig. - Anime recommendation for One-Piece.
        </figcaption>
    </div>
</div>




<br>
<br>

### Results deduced from the dataset

<div style="display: flex; justify-content: flex-start; margin: 6px;">
    <div style="text-align: center; width: 1250px;">
        <img src="screenshots\top_10_anime.png" alt="Top 10 Anime of all time" style="width: 100%; height: 550px; margin: 6px;" />
        <figcaption style="background-color: #0f0f0f; color: white; font-style: italic; padding: 2px;">
            Fig. - Top 10 Anime of all time.
        </figcaption>
    </div>
</div>

<br>
<br>
<div style="display: flex; justify-content: flex-start; margin: 6px;">
    <div style="text-align: center; width: 1250px;">
        <img src="screenshots\top_anime_by_genre_tags.png" alt="Top 10 Anime by Genre/Tags" style="width: 100%; height: 550px; margin: 6px;" />
        <figcaption style="background-color: #0f0f0f; color: white; font-style: italic; padding: 2px;">
            Fig. - Top 10 Anime by Genre/Tags.
        </figcaption>
    </div>
</div>
<br>
<br>

<div style="display: flex; justify-content: flex-start; margin: 6px;">
    <div style="text-align: center; width: 1250px;">
        <img src="screenshots\top_anime_by_studios.png" alt="Top 10 Anime by particular studio" style="width: 100%; height: 550px; margin: 6px;" />
        <figcaption style="background-color: #0f0f0f; color: white; font-style: italic; padding: 2px;">
            Fig. - Top 10 Anime by particular studio.
        </figcaption>
    </div>
</div>


<br>
<br>
<br>

# TODO
- [ ] Make a better UI
- [ ] Make a responsive UI
- [ ] Add theme switch functionality
- [ ] Recommend top anime by each studio
- [ ] Recommend Top anime based on Genre/Tags
- [ ] Add more anime data
- [ ] Add User Login and user-feedback to improver model
- [ ] Add more anime data along with banner






<br>
<br>
<br>

Made with Flutter :blue_heart: