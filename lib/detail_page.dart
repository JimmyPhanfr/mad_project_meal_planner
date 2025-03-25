import 'dart:convert';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String ingredientsJson;
  final String instructionsJson;
  final String image;

  const DetailScreen({super.key, 
    required this.title,
    required this.ingredientsJson,
    required this.instructionsJson,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    List<String> ingredients = List<String>.from(jsonDecode(ingredientsJson));
    List<String> instructions = List<String>.from(jsonDecode(instructionsJson));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  for (var ingredient in ingredients)
                    Text(
                      ingredient,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(height: 20.0),
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  for (var instruction in instructions)
                    Text(
                      instruction,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
