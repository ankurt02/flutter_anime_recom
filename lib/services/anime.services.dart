import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeService {
  static Future<List<Map<String, dynamic>>> getRecommendations(String animeName) async {
    final url = Uri.parse('http://127.0.0.1:5000/recommend'); // Use your local IP for physical devices
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': animeName}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['recommendations']);
      } else {
        throw Exception('Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
