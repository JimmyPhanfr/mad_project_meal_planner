import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_db.dart';
import 'user.dart';

class UserActions {
  final BuildContext context;
  User currentUser;
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  final Function(User) updateUser;
  final Function(List<Map<String, dynamic>>) updateFilteredRecipes;

  UserActions({
    required this.context, 
    required this.currentUser, 
    required this.recipes,
    required this.updateUser,
    required this.updateFilteredRecipes,
  });

  List<Map<String, dynamic>> get filteredRecipes => _filteredRecipes;

  void filterRecipes(String query) {
    final filtered = recipes.where((recipe) {
      final tags = List<String>.from(jsonDecode(recipe['tags']));
      final searchQuery = query.toLowerCase();
      return tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
    _filteredRecipes = filtered;
    updateFilteredRecipes(_filteredRecipes);
  }

  Future<void> addToFavorites(Map<String, dynamic> recipe) async {
    List<String> updatedFavorites = List<String>.from(currentUser.favorites);
    if (!updatedFavorites.contains(recipe['id'].toString())) {
      updatedFavorites.add(recipe['id'].toString());
      User updatedUser = currentUser.copyWith(favorites: updatedFavorites);
      await UserDB().updateUser(updatedUser);
      currentUser = updatedUser;
      updateUser(currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} added to favorites!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} is already in favorites!')),
      );
    }
  }

  Future<void> removeFromFavorites(Map<String, dynamic> recipe) async {
    List<String> updatedFavorites = List<String>.from(currentUser.favorites);
    if (updatedFavorites.contains(recipe['id'].toString())) {
      updatedFavorites.remove(recipe['id'].toString());
      User updatedUser = currentUser.copyWith(favorites: updatedFavorites);
      await UserDB().updateUser(updatedUser);
      currentUser = updatedUser;
      updateUser(currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} removed from favorites!')),
      );
    }
  }

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
    for (String ingredient in ingredients) {
      updatedGroceries[ingredient] = (updatedGroceries[ingredient] ?? 0) + 1;
    }
    currentUser = currentUser.copyWith(todorecipes: updatedTodorecipes, groceries: updatedGroceries);
    await UserDB().updateUser(currentUser);
    updateUser(currentUser);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe scheduled for $date!')),
    );
  }

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
