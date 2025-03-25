import 'package:flutter/material.dart';
import 'search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MealPrepApp());
}

class MealPrepApp extends StatelessWidget {
  const MealPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}