import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie_api_service.dart';

class FetchMoviesScreen extends StatefulWidget {
  @override
  _FetchMoviesScreenState createState() => _FetchMoviesScreenState();
}

class _FetchMoviesScreenState extends State<FetchMoviesScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _loading = false;
  List<dynamic> _movies = [];

  Future<void> _fetchMovies() async {
    setState(() {
      _loading = true;
    });

    try {
      final movies = await MovieApiService().fetchMovies();
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch movies: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addMovieToFirebase(Map<String, dynamic> movie) async {
    await _firestore.collection('movies').add({
      'title': movie['title'],
      'year': movie['release_date']?.split('-')[0] ?? 'Unknown',
      'director': 'N/A', // TMDb API doesn't provide director info.
      'genre': 'N/A', // Add logic for genres if required.
      'synopsis': movie['overview'],
      'imageUrl': 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${movie['title']} added to Firebase')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchMovies,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _movies.isEmpty
          ? Center(child: Text('No movies fetched.'))
          : ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return ListTile(
            leading: Image.network(
              'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image),
            ),
            title: Text(movie['title']),
            subtitle:
            Text('Year: ${movie['release_date']?.split('-')[0] ?? 'Unknown'}'),
            trailing: IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () => _addMovieToFirebase(movie),
            ),
          );
        },
      ),
    );
  }
}
