import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieDetailScreen extends StatelessWidget {
  final String movieId;

  MovieDetailScreen({required this.movieId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('movies').doc(movieId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading movie details.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Movie not found.'));
          }

          final movie = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie['title'], style: TextStyle(fontSize: 24)),
                  SizedBox(height: 10),
                  Text('Year: ${movie['year']}'),
                  Text('Director: ${movie['director']}'),
                  Text('Genre: ${movie['genre']}'),
                  SizedBox(height: 10),
                  Text(movie['synopsis']),
                  SizedBox(height: 20),
                  Image.network(
                    movie['imageUrl'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Failed to load image.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
