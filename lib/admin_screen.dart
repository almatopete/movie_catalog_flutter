import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fetch_movies_screen.dart'; // New screen for fetching movies.

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('roles').doc(user.uid).get();
      setState(() {
        _isAdmin = doc.exists && doc['role'] == 'admin';
        _loading = false;
      });
    } else {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
    }
  }

  void _addMovie() async {
    if (_titleController.text.isEmpty || _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Image URL are required.')),
      );
      return;
    }

    await _firestore.collection('movies').add({
      'title': _titleController.text,
      'year': _yearController.text,
      'director': _directorController.text,
      'genre': _genreController.text,
      'synopsis': _synopsisController.text,
      'imageUrl': _imageUrlController.text,
    });
    _clearFields();
  }

  void _deleteMovie(String id) async {
    await _firestore.collection('movies').doc(id).delete();
  }

  void _clearFields() {
    _titleController.clear();
    _yearController.clear();
    _directorController.clear();
    _genreController.clear();
    _synopsisController.clear();
    _imageUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('Unauthorized')),
        body: Center(
          child: Text(
            'You are not authorized to access this page.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FetchMoviesScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('movies').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No movies found.'));
                  }

                  final movies = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index].data() as Map<String, dynamic>;
                      final movieId = movies[index].id;

                      return ListTile(
                        leading: Image.network(
                          movie['imageUrl'],
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                        ),
                        title: Text(movie['title']),
                        subtitle: Text('Year: ${movie['year']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMovie(movieId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(),
            SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _yearController,
                    decoration: InputDecoration(labelText: 'Year'),
                  ),
                  TextField(
                    controller: _directorController,
                    decoration: InputDecoration(labelText: 'Director'),
                  ),
                  TextField(
                    controller: _genreController,
                    decoration: InputDecoration(labelText: 'Genre'),
                  ),
                  TextField(
                    controller: _synopsisController,
                    decoration: InputDecoration(labelText: 'Synopsis'),
                  ),
                  TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addMovie,
                    child: Text('Add Movie'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
