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
    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white
        ),
        color: Colors.black54,
      ),
      child: ListTile(
        title: Text(name),
        subtitle: Text('Rating: ${rating.toStringAsFixed(1)} | Episodes: $seasons'),
      ),
    );
  }
}
