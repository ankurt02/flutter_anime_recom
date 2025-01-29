class Anime {
  final String name;
  final double rating;
  final int episodes;

  Anime({
    required this.name,
    required this.rating,
    required this.episodes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      name: json['Name'],
      rating: json['Rating Score'],
      episodes: json['Episodes'],
    );
  }
}