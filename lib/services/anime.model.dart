  class Anime {
    final String name;
    final double rating;
    final int episodes;
    final String? imageUrl; // Add this field

    Anime({
      required this.name,
      required this.rating,
      required this.episodes,
      this.imageUrl, // Add to constructor
    });

    // A helper method to create a new instance with an updated image URL
    Anime copyWith({String? imageUrl}) {
      return Anime(
        name: this.name,
        rating: this.rating,
        episodes: this.episodes,
        imageUrl: imageUrl ?? this.imageUrl,
      );
    }

    factory Anime.fromJson(Map<String, dynamic> json) {
      return Anime(
        name: json['Name'],
        rating: (json['Rating Score'] as num).toDouble(),
        episodes: (json['Episodes'] as num).toInt(),
      );
    }

    static List<Anime> getTopAnime() {
      return [
        Anime(name: "Naruto Shippuden", rating: 8.7, episodes: 500),
        Anime(name: "Bleach", rating: 8.1, episodes: 366),
        Anime(name: "One-Piece", rating: 8.6, episodes: 1000),
        Anime(name: "Attack on Titan", rating: 9.0, episodes: 75),
        Anime(name: "Fullmetal Alchemist: Brotherhood", rating: 9.2, episodes: 64),
        Anime(name: "Tokyo Ghoul", rating: 7.8, episodes: 48),
        Anime(name: "Death Note", rating: 9.0, episodes: 37),
        Anime(name: "My Hero Academia", rating: 8.0, episodes: 113),
        Anime(name: "Sword Art Online", rating: 7.6, episodes: 96),
        Anime(name: "Demon Slayer", rating: 8.7, episodes: 44),
        Anime(name: "One-Punch Man", rating: 8.8, episodes: 24),
      ];
    }
  }