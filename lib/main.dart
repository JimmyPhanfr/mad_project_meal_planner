import 'package:flutter/material.dart';
import 'dart:core';
import 'login_page.dart';
//import 'user_db.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //String path = join(await getDatabasesPath(), 'users.db');
  //await deleteDatabase(path);
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