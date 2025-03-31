import 'dart:convert';
import 'package:flutter/material.dart';
import 'user.dart';
import 'user_actions.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String title;
  final String ingredientsJson;
  final String instructionsJson;
  final String image;
  User user;
  final Function(int, bool) onFavoriteChanged;
  final Function(User) updateUser;
  final Function(List<Map<String, dynamic>>) updateFilteredRecipes;
  final List<Map<String, dynamic>> recipes;

  DetailScreen({super.key, 
    required this.id,
    required this.title,
    required this.ingredientsJson,
    required this.instructionsJson,
    required this.image,
    required this.user,
    required this.onFavoriteChanged,
    required this.updateUser,
    required this.updateFilteredRecipes,
    required this.recipes,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late List<String> ingredients;
  late List<String> instructions;
  late UserActions userActions;
  final List<Map<String, dynamic>> _filteredRecipes = []; //required for usserActions class, but unneeded for this class, kept empty
  late Map<String, dynamic> recipe;
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    ingredients = List<String>.from(jsonDecode(widget.ingredientsJson));
    instructions = List<String>.from(jsonDecode(widget.instructionsJson));
    userActions = UserActions(
      context: context, 
      currentUser: widget.user, 
      recipes: widget.recipes, 
      updateUser: widget.updateUser,
      updateFilteredRecipes: widget.updateFilteredRecipes,
    );
    recipe = {
      'id' : widget.id,
      'title' : widget.title,
    };
    isFavorited = widget.user.favorites.contains(widget.id.toString());
  }

  //used for toggling favorite recipes, adding or removing from favorite list
  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
      if (isFavorited) {
        userActions.addToFavorites(recipe);
      } else {
        userActions.removeFromFavorites(recipe);
      }
      widget.onFavoriteChanged(widget.id, isFavorited);
      widget.updateUser(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
              widget.image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          Padding( //lists the details of the recipe such as ingredients and instructions
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.green[800],
          border: Border(
            top: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon( //for user to favorite or unfavorite the recipe
              onPressed: toggleFavorite,
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.blueGrey,
              ),
              label: Text(isFavorited ? 'Unfavorite' : 'Favorite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: ()  async {
                String? selectedDate = await userActions.selectDate(); //for user to select a date for the recipe
                print(selectedDate);
                if (selectedDate != null) {
                  print('date was not null');
                  setState(() {
                    print('Entering user actions');
                    userActions.addToTodorecipes(widget.id.toString(), selectedDate);
                    widget.updateUser(widget.user);
                  });
                } else {
                  print('date is null');
                }
              },
              icon: Icon(Icons.access_alarm_outlined, color: Colors.white),
              label: Text('Add to To-Do'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
