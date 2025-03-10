// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/anime.model.dart';
import '../widgets/anime.card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: RecommendationScreen(),
    );
  }
}



class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Anime> recommendations = [];
  String errorMessage = "";

  Future<void> fetchRecommendations(String animeTitle) async {
    final url = Uri.parse("http://127.0.0.1:5000/recommend");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": animeTitle}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendations = List<Anime>.from(
            data['recommendations'].map((anime) => Anime.fromJson(anime))
          );
          errorMessage = "";
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
        errorMessage = "Couldn't find recommendations for this anime.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anime Recommendation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter Anime Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchRecommendations(_controller.text);
                }
              },
              child: Text("Get Recommendations"),
            ),
            SizedBox(height: 16),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            if (recommendations.isNotEmpty)
              Expanded(
                 child: ListView.builder(
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                        final anime = recommendations[index];
                    return AnimeCard(
                        name: anime.name,
                        rating: anime.rating,
                        seasons: anime.episodes, // Use episodes here, as AnimeCard expects 'seasons'
      );
    },
  ),
),

          ],
        ),
      ),
    );
  }
}
