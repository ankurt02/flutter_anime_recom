// ignore_for_file: prefer_const_constructors

// screens/recommendation_screen.dart

import 'dart:convert';
import 'package:anime_rec/services/anime.model.dart';
import 'package:anime_rec/widgets/anime.card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;   // Make sure this path is correct

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Anime> recommendations = [];
  String errorMessage = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialTopAnime();
  }
  
  Future<void> _fetchInitialTopAnime() async {
    setState(() => isLoading = true);
    List<Anime> topAnime = Anime.getTopAnime();
    List<Anime> enrichedAnime = await _enrichAnimeListWithImages(topAnime);
    setState(() {
      recommendations = enrichedAnime;
      isLoading = false;
    });
  }

  Future<List<Anime>> _enrichAnimeListWithImages(List<Anime> animeList) async {
    List<Anime> enrichedList = [];
    for (final anime in animeList) {
      final imageUrl = await JikanService.fetchAnimeImageUrl(anime.name);
      enrichedList.add(anime.copyWith(imageUrl: imageUrl));
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return enrichedList;
  }

  Future<void> fetchRecommendations(String animeTitle) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final url = Uri.parse("http://127.0.0.1:5000/recommend");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": animeTitle}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Anime> initialRecommendations = List<Anime>.from(
          data['recommendations'].map((anime) => Anime.fromJson(anime)),
        );
        final enrichedRecommendations = await _enrichAnimeListWithImages(initialRecommendations);
        setState(() {
          recommendations = enrichedRecommendations;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          recommendations = [];
          errorMessage = data['error'];
        });
      }
    } catch (e) {
      setState(() {
        recommendations = [];
        errorMessage = "Couldn't connect or find recommendations.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anime Recommendation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter Anime Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchRecommendations(_controller.text);
                }
              },
              child: const Text("Get Recommendations"),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              )
            else ...[
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_controller.text.isEmpty && errorMessage.isEmpty)
                const Text(
                  "Top Anime",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              if (recommendations.isNotEmpty)
               Expanded(
    // Use LayoutBuilder to get the screen constraints
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Define a breakpoint for mobile width
        bool isMobile = constraints.maxWidth < 600;

        Widget listView = ListView.builder(
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final anime = recommendations[index];
            return AnimeCard(
              name: anime.name,
              rating: anime.rating,
              seasons: anime.episodes,
              imageUrl: anime.imageUrl,
            );
          },
        );

        if (isMobile) {
          // On mobile, return the list view directly to fill the width
          return listView;
        } else {
          // On desktop/wide screens, center the list in a constrained box
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Set the max width to 65% of the available space
                maxWidth: constraints.maxWidth * 0.65,
              ),
              child: listView,
            ),
          );
        }
      },
    ),
  ),
            ],
          ],
        ),
      ),
    );
  }
}
