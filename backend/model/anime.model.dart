class Anime {
  final String name;
  final double rating;
  final int seasons;

  Anime({
    required this.name,
    required this.rating,
    required this.seasons,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      name: json['name'],
      rating: json['rating'],
      seasons: json['seasons'],
    );
  }
}
