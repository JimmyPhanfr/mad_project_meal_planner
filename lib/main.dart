import 'package:flutter/material.dart';
import 'dart:core';
import 'login_page.dart';
import 'user_db.dart';
import 'recipe_db.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*String userPath = join(await getDatabasesPath(), 'users.db');
  await deleteDatabase(userPath);
  String recipePath = join(await getDatabasesPath(), 'recipes.db');
  await deleteDatabase(recipePath);*/
  runApp(MealPrepApp());
}

class MealPrepApp extends StatelessWidget {
  const MealPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}