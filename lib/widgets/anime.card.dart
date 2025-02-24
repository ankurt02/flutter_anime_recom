import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AnimeCard extends StatelessWidget {
  
  final String name;
  final double rating;
  final int seasons;

  const AnimeCard({super.key, 
    required this.name,
    required this.rating,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white
        ),
        color: Colors.black54,
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(6),
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.amber,

              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text('image'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left : 6.0, right: 4.0),
              child: Column(
            
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(
                    fontSize: 18,
                    // overflow: TextOverflow.visible,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(50),
                  Text('Rating: ⭐ ${rating.toStringAsFixed(1)} \nEpisodes: $seasons')
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
