import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApiService {
  final String _baseUrl = "https://api.themoviedb.org/3";
  final String _apiKey = "e3b6f52a6b63d71b085e5b3fb25c3e21"; // Replace with your TMDb API key.

  Future<List<dynamic>> fetchMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception("Failed to load movies");
    }
  }
}
