import 'package:anime_rec/core/logger.dart';

import 'dart:convert';
import 'package:anime_rec/services/anime.model.dart';
import 'package:anime_rec/widgets/anime.card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Make sure this path is correct

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
    try {
      logger.i("INIT : Fetching top anime", tag: "INIT");
      setState(() => isLoading = true);
      List<Anime> topAnime = Anime.getTopAnime();
      List<Anime> enrichedAnime = await _enrichAnimeListWithImages(topAnime);
      setState(() {
        recommendations = enrichedAnime;
      });
    } catch (e, stackTrace) {
      logger.e("INIT ERROR",
          error: 2, stackTrace: stackTrace, tag: "INIT Error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Anime>> _enrichAnimeListWithImages(List<Anime> animeList) async {
    logger.i("Starting image fetching", tag: "IMAGE-FETCHING");
    List<Anime> enrichedList = [];
    for (final anime in animeList) {
      try {
        logger.d("Fetching image for : ${anime.name}");
        final imageUrl = await JikanService.fetchAnimeImageUrl(anime.name);
        logger.d("Image fetched : ${anime.name} -> $imageUrl");
        enrichedList.add(anime.copyWith(imageUrl: imageUrl));
      } catch (e) {
        logger.e("IMAGE FETCH FAILED : ${anime.name}", error: e);
        // enrichedList.add(anime);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    logger.i("ENRICH COMPLETE : ${enrichedList.length} items");
    return enrichedList;
  }

  Future<void> fetchRecommendations(String animeTitle) async {
    logger.i("API CALL STARTED");
    logger.d("User input: $animeTitle");
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final url =
        Uri.parse("https://ankurt02-anime-recommender-api.hf.space/recommend");
    try {
      logger.d("Sending POST request to: $url");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": animeTitle}),
      );

      logger.i("RESPONSE RECEIVED");
      logger.d("Status Code: ${response.statusCode}");
      logger.d("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Anime> initialRecommendations = List<Anime>.from(
          data['recommendations'].map((anime) {
            logger.d("Parsing anime : ${anime.toString()}");
            return Anime.fromJson(anime);
          }),
        );

        logger.i("Parsed ${initialRecommendations.length} recommendations");

        final enrichedRecommendations =
            await _enrichAnimeListWithImages(initialRecommendations);
        setState(() {
          recommendations = enrichedRecommendations;
        });
        logger.i("UI UPDATED with recommendations");
      } else {
        logger.w("Non-200 response received");

        try {
          final data = jsonDecode(response.body);
          errorMessage = data['error'] ?? "Unknown server error";
        } catch (_) {
          errorMessage = "Server error: ${response.statusCode}";
        }

        setState(() {
          recommendations = [];
        });
      }
    } catch (e, stackTrace) {
      logger.e("API call FAILED", error: e, stackTrace: stackTrace);
      setState(() {
        recommendations = [];
        errorMessage = "Connection Failed.";
      });
    } finally {
      logger.i("API call ended");
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
