import 'package:anime_rec/core/logger.dart';
import 'dart:convert';
import 'package:anime_rec/services/anime.model.dart';
import 'package:anime_rec/widgets/anime.card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
          error: e, stackTrace: stackTrace, tag: "INIT Error");
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

        if (imageUrl != null && imageUrl.isNotEmpty) {
          enrichedList.add(anime.copyWith(imageUrl: imageUrl));
        } else {
          enrichedList.add(anime.copyWith(
            imageUrl: "assets/images/fallback_image.png",
          ));
        }
      } catch (e) {
        logger.e("IMAGE FETCH FAILED : ${anime.name}", error: e);

        enrichedList.add(anime.copyWith(
          imageUrl: "assets/images/fallback_image.png",
        ));
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    logger.i("ENRICH COMPLETE : ${enrichedList.length} items");
    return enrichedList;
  }

 Future<void> fetchRecommendations(String animeTitle) async {
  logger.i("API CALL STARTED");

  setState(() {
    isLoading = true;
    errorMessage = "";
  });

  final url = Uri.parse(
    "https://ankurt02-anime-recommender-api.hf.space/recommend",
  );

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"title": animeTitle}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<Anime> initialRecommendations = List<Anime>.from(
        data['recommendations'].map((anime) {
          return Anime.fromJson(anime);
        }),
      );

      final enrichedRecommendations =
          await _enrichAnimeListWithImages(initialRecommendations);

      setState(() {
        recommendations = enrichedRecommendations;
      });
    } else {
      setState(() {
        recommendations = [];
        errorMessage = "Server error: ${response.statusCode}";
      });
    }
  } catch (e) {
    // 🔥 PRINT REAL ERROR
    print("API ERROR: $e");

    setState(() {
      recommendations = [];
      errorMessage = "Connection Failed.";
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
      backgroundColor: const Color(0xFFf4f4f0),
      appBar: AppBar(
        title: Text(
          "Shikamaru-ai",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: 500,
              child: TextField(
  controller: _controller,
  cursorColor: Colors.black87, // 🔥 cursor color
  style: TextStyle(
    color: Colors.grey.shade900, // dark grey / near black
    fontSize: 16,
  ),

  decoration: InputDecoration(
    labelText: "Enter Anime Name",

    // 🔥 LABEL COLORS
    labelStyle: TextStyle(color: Colors.grey.shade700),
    floatingLabelStyle: TextStyle(color: Colors.black87),

    // 🔥 BORDER (NORMAL)
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade500),
    ),

    // 🔥 BORDER (FOCUSED)
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.black87,
        width: 2,
      ),
    ),
  ),
),
            ),
            const Gap(18),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchRecommendations(_controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF69E07),
                foregroundColor: Colors.white,
              ),
              child: const Text("Get Recommendations"),
            ),
            const SizedBox(height: 16),

            /// LOADING
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              )

            /// CONTENT
            else ...[
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              if (_controller.text.isEmpty && errorMessage.isEmpty)
                const Text(
                  "Top Anime",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              if (recommendations.isNotEmpty)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final topAnime = recommendations.take(10).toList();

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: GridView.builder(
                            itemCount: topAnime.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 3.2,
                            ),
                            itemBuilder: (context, index) {
                              final anime = topAnime[index];

                              return Stack(
                                children: [
                                  AnimeCard(
                                    name: anime.name,
                                    rating: anime.rating,
                                    seasons: anime.episodes,
                                    imageUrl: anime.imageUrl,
                                  ),

                                  // 🔺 TRIANGLE
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Stack(
                                        children: [
                                          CustomPaint(
                                            size: const Size(60, 60),
                                            painter: TrianglePainter(
                                              (index == 0)
                                                  ? const Color.fromARGB(255, 252, 177, 48) // 🥇
                                                  : (index == 1)
                                                      ? Colors
                                                          .grey.shade400 // 🥈
                                                      : (index == 2)
                                                          ? const Color.fromARGB(255, 181, 100, 1) // 🥉
                                                          : Colors.black
                                                              .withOpacity(0.8),
                                            ),
                                          ),

                                          // 🔥 NUMBER
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();

    double r = 12; // 🔥 smooth only top-left

    path.moveTo(r, 0);

    // 🔥 TOP EDGE (sharp on right)
    path.lineTo(size.width, 0);

    // 🔥 RIGHT EDGE (sharp)
    path.lineTo(0, size.height);

    // 🔥 LEFT EDGE up
    path.lineTo(0, r);

    // 🔥 ONLY smooth top-left corner
    path.quadraticBezierTo(
      0,
      0,
      r,
      0,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
