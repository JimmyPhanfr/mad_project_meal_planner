import 'recipe_db.dart';
import 'user_db.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';

import 'home_page.dart';
import 'favorite_page.dart';
import 'search_page.dart';
import 'planner_page.dart';
import 'accounts_page.dart';

class FavoritePage extends StatefulWidget {
  final User currentUser;

  const FavoritePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<String> favoriteRecipeIds;
  List<Map<String, dynamic>> favoriteRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  late User _currentUser;
  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    favoriteRecipeIds = List<String>.from(widget.currentUser.favorites);
  }

  _removeFromFavorites(Map<String, dynamic> recipe) async {
    List<String> updatedFavorites = List<String>.from(_currentUser.favorites);
    if (updatedFavorites.contains(recipe['id'].toString())) {
      updatedFavorites.remove(recipe['id'].toString());
      User updatedUser = _currentUser.copyWith(favorites: updatedFavorites);
      await UserDB().updateUser(updatedUser);
      setState(() {
        _currentUser = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} removed from favorites!')),
      );
    }
  }

  _addToTodorecipes(String recipeId, String date) async {
    List<Map<String, String>> updatedTodorecipes = List.from(_currentUser.todorecipes);
    updatedTodorecipes.add({'recipeId': recipeId, 'date': date});
    User updatedUser = _currentUser.copyWith(todorecipes: updatedTodorecipes);
    await UserDB().updateUser(updatedUser);
    setState(() {
      _currentUser = updatedUser;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe scheduled for $date!')),
    );
  }

  Future<String?> _selectDate(BuildContext context) async {
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

  _filterRecipes(String query) {
    final filtered = favoriteRecipes.where((recipe) {
      final title = recipe['title'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery);
    }).toList();
    setState(() {
      _filteredRecipes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              onChanged: _filterRecipes,
              decoration: InputDecoration(
                hintText: "Search favorite recipes...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                final isFavorite = favoriteRecipeIds.contains(recipe['id'].toString());

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          title: recipe['title'],
                          ingredientsJson: recipe['ingredients'],
                          instructionsJson: recipe['instructions'],
                          image: recipe['image'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 6.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.white, width: 2.0),
                        image: DecorationImage(
                          image: AssetImage(recipe['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.restaurant_menu, size: 45.0, color: Colors.white),
                                const SizedBox(height: 10.0),
                                Text(
                                  recipe['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () => _removeFromFavorites(recipe),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.access_alarm_outlined, color: Colors.white),
                              onPressed: () async {
                                String? selectedDate = await _selectDate(context);
                                if (selectedDate != null) {
                                  _addToTodorecipes(recipe['id'].toString(), selectedDate);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60.0,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: _currentUser)),);
              },
              icon: Icon(Icons.home),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: new BoxDecoration(
                color: Colors.lightGreenAccent,
                borderRadius: new BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FavoritePage(currentUser: _currentUser)),);
                },
                icon: Icon(Icons.favorite),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage(user: _currentUser)),);
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlannerPage(user: _currentUser)),);
              },
              icon: Icon(Icons.list),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountsPage(user: _currentUser)),);
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}




