import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_catalog_flutter/welcome_screen.dart';

import 'admin_screen.dart';
import 'catalog_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Catalog',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/catalog': (context) => CatalogScreen(),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}

