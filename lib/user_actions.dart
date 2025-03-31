import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_db.dart';
import 'user.dart';

class UserActions {
  final BuildContext context;
  User currentUser;
  List<Map<String, dynamic>> recipes = []; //list of all recipes in this use case
  List<Map<String, dynamic>> _filteredRecipes = []; //list of recipes that fit a filter criteria
  final Function(User) updateUser; //function to update the user in the parent widget/class
  final Function(List<Map<String, dynamic>>) updateFilteredRecipes; //function to update the list of filtered recipes in the parent widget/class

  UserActions({
    required this.context, 
    required this.currentUser, 
    required this.recipes,
    required this.updateUser,
    required this.updateFilteredRecipes,
  });

  //searches the list of all recipes that contain a search criteria, lists all the recipes that have a tag that fits the search criteria
  void filterRecipes(String query) {
    _filteredRecipes = recipes.where((recipe) {
      final tags = List<String>.from(jsonDecode(recipe['tags']));
      final searchQuery = query.toLowerCase();
      return tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
    updateFilteredRecipes(_filteredRecipes);
  }

  //adds a recipe to the user's list of favorite recipes
  Future<void> addToFavorites(Map<String, dynamic> recipe) async {
    List<String> updatedFavorites = List<String>.from(currentUser.favorites);
    print(updatedFavorites);
    if (!updatedFavorites.contains(recipe['id'].toString())) {
      updatedFavorites.add(recipe['id'].toString());
      currentUser = currentUser.copyWith(favorites: updatedFavorites); //updates the user object in useractions class
      await UserDB().updateUser(currentUser); //updates the user in the database
      updateUser(currentUser); //updates the user object in the parent widget
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} added to favorites!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} is already in favorites!')),
      );
    }
  }

  //removes a recipe from the user's list of favorite recipes
  Future<void> removeFromFavorites(Map<String, dynamic> recipe) async {
    List<String> updatedFavorites = List<String>.from(currentUser.favorites);
    print(updatedFavorites);
    if (updatedFavorites.contains(recipe['id'].toString())) {
      updatedFavorites.remove(recipe['id'].toString());
      currentUser = currentUser.copyWith(favorites: updatedFavorites); //updates the user object in useractions class
      await UserDB().updateUser(currentUser); //updates the user in the database
    updateUser(currentUser); //updates the user object in the parent widget
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} removed from favorites!')),
      );
    }
  }

  //adds a recipe to the user's list of todo recipes, also adds the recipe's ingredients to the user's grocery list
  Future<void> addToTodorecipes(String recipeId, String date) async {
    List<Map<String, String>> updatedTodorecipes = List.from(currentUser.todorecipes);
    Map<String, int>? updatedGroceries = Map.from(currentUser.groceries);
    Map<String, dynamic>? recipe = recipes.firstWhere((recipe) => recipe['id'].toString() == recipeId, orElse: () => {}); 
    if (recipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Recipe not found!')),
      );
      return;
    }
    updatedTodorecipes.add({'recipeId': recipeId, 'date': date}); 
    List<String> ingredients = List<String>.from(jsonDecode(recipe['ingredients'])); 
    for (String ingredient in ingredients) { //adds the ingredient to the grocery list, increments the grocery quantity by one if it exists, otherwise a default of 1 is put
      updatedGroceries[ingredient] = (updatedGroceries[ingredient] ?? 0) + 1;
    }
    currentUser = currentUser.copyWith(todorecipes: updatedTodorecipes, groceries: updatedGroceries); //updates the user object in useractions class
    await UserDB().updateUser(currentUser); //updates the user in the database
    updateUser(currentUser); //updates the user object in the parent widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe scheduled for $date!')),
    );
  }

  //removes a recipe from the user's list of todo recipes, also removes the recipe's ingredients from the user's grocery list
  Future<void> removeFromTodorecipes(String recipeId, String date) async {
    List<Map<String, String>> updatedTodorecipes = List.from(currentUser.todorecipes);
    Map<String, int>? updatedGroceries = Map.from(currentUser.groceries);
    Map<String, dynamic>? recipe = recipes.firstWhere((recipe) => recipe['id'].toString() == recipeId, orElse: () => {});
    if (recipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Recipe not found!')),
      );
      return;
    }
    updatedTodorecipes.removeWhere((entry) => entry['recipeId'] == recipeId && entry['date'] == date);
    List<String> ingredients = List<String>.from(jsonDecode(recipe['ingredients']));
    for (String ingredient in ingredients) { //removes the ingredient from the grocery list, decrements the grocery quantity by one if it exists, removing any ingredients that are at 0 or less from the grocery list
      if (updatedGroceries.containsKey(ingredient)) {
        updatedGroceries[ingredient] = (updatedGroceries[ingredient]! - 1);
        if (updatedGroceries[ingredient]! <= 0) {
          updatedGroceries.remove(ingredient);
        }
      }
    }
    currentUser = currentUser.copyWith(todorecipes: updatedTodorecipes, groceries: updatedGroceries); //updates the user object in useractions class
    await UserDB().updateUser(currentUser); //updates the user in the database
    updateUser(currentUser); //updates the user object in the parent widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe removed from schedule!')),
    );
  }

  //selecting a date from the calendar widget, returns the selected date
  Future<String?> selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate);
    }
    return null;
  }
}
