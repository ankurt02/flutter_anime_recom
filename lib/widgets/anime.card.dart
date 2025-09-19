import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


// services/jikan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class JikanService {
  static Future<String?> fetchAnimeImageUrl(String animeName) async {
    // URL-encode the anime name to handle spaces and special characters
    final encodedAnimeName = Uri.encodeComponent(animeName);
    final url = Uri.parse('https://api.jikan.moe/v4/anime?q=$encodedAnimeName&limit=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the 'data' list is not empty
        if (data['data'] != null && data['data'].isNotEmpty) {
          // Safely get the image URL
          return data['data'][0]['images']['jpg']['image_url'];
        }
      }
      // Return null if no image is found or if there's an API error
      return null;
    } catch (e) {
      print('Error fetching image from Jikan: $e');
      return null;
    }
  }
}

// import 'network_image_with_dio.dart';
// 1. Create the key-value pair (Map) for top 20 anime and their image URLs


// Helper function to standardize anime names
String standardizeAnimeName(String name) {
  return name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'), ''); // remove all non-alphanumeric characters
}

// Create a standardized map for lookup
// final Map<String, String> standardizedTopAnimeI/mages = topAnimeImages
    // .map((key, value) => MapEntry(standardizeAnimeName(key), value));

class AnimeCard extends StatelessWidget {
  final String name;
  final double rating;
  final int seasons;
  final String? imageUrl;

  const AnimeCard({
    super.key,
    required this.name,
    required this.rating,
    required this.seasons,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 136,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
        color: Colors.black54,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 90,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl ?? 'https://via.placeholder.com/90x120.png?text=No+Image',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/fallback_image.png', // Ensure this file exists
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating: ⭐ ${rating.toStringAsFixed(1)}'),
                      const Gap(4),
                      Text('Episodes: $seasons'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

class NetworkImageWithDio extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const NetworkImageWithDio({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  static const List<String> assetImages = [
    'images/img_eef.jpg',
    'images/r1imag.jpg',
    'images/twoimg.jpg',
    'images/download.jpg',
    'images/fivei.jpg',
    'images/fouri.jpg',
    'images/Ichigo.jpg',
    'images/threei.jpg',
    'images/sixi.jpg',
    'images/seveni.jpg',
    'images/eighti.jpg',
    'images/ninei.jpg',
    'images/teni.jpg',
    'images/eleveni.jpg',
    'images/twelvei.jpg'
  ];

  Future<Uint8List> fetchImageBytes(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: fetchImageBytes(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              'images/r1imag.jpg', // Use a default image
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: BoxFit.contain,
            ),
          );
        }
      },
    );
  }
}
