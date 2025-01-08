import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final String name;
  final double rating;
  final int seasons;

  AnimeCard({
    required this.name,
    required this.rating,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text('Rating: $rating | Seasons: $seasons'),
      ),
    );
  }
}
