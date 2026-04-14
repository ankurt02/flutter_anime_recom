import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gap/gap.dart';

// services/jikan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/logger.dart';

/// Wraps any MAL image URL with wsrv.nl proxy.
/// wsrv.nl caches images, bypasses hotlink protection and CORS on all platforms.
String getProxiedImageUrl(String malImageUrl) {
  return 'https://wsrv.nl/?url=$malImageUrl';
}

class JikanService {
  static Future<String?> fetchAnimeImageUrl(String animeName) async {
    final encodedAnimeName = Uri.encodeComponent(animeName);
    final url =
        Uri.parse('https://api.jikan.moe/v4/anime?q=$encodedAnimeName&limit=1');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'AnimeRecApp/1.0'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final images = data['data'][0]['images'];

          // Prefer .jpg large image, fall back to webp
          String? imageUrl = images['jpg']?['large_image_url'] ??
              images['jpg']?['image_url'] ??
              images['webp']?['large_image_url'] ??
              images['webp']?['image_url'];

          if (imageUrl == null || imageUrl.isEmpty) {
            logger.w("No image URL in Jikan response for: $animeName");
            return null;
          }

          // Always proxy through wsrv.nl — works on both web and native.
          // This replaces corsproxy.io (which gives 403) and fixes
          // the statusCode: 0 issue from direct MAL URLs.
          final proxiedUrl = getProxiedImageUrl(imageUrl);
          logger.d("Proxied URL for $animeName: $proxiedUrl");
          return proxiedUrl;
        }
      } else {
        logger.w("Jikan API non-200 for $animeName: ${response.statusCode}");
      }
      return null;
    } catch (e) {
      logger.e("Error fetching image from Jikan for $animeName", error: e);
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      height: 240,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Padding(
        // 🔥 SHIFT EVERYTHING RIGHT
        padding: const EdgeInsets.only(left: 28),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              width: 90,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    logger.e("Image loading error for $name: $error");
                    return Image.asset(
                      'assets/images/fallback_image.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating: ⭐ ${rating.toStringAsFixed(1)}',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const Gap(4),
                        Text(
                          'Episodes: $seasons',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
