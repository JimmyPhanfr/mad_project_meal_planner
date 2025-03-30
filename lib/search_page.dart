import 'dart:convert';
import 'package:mealprep/navbar.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'package:flutter/material.dart';
import 'recipe_db.dart';
import 'user.dart';
import 'user_actions.dart';

class SearchPage extends StatefulWidget {
  final User user;
  const SearchPage({Key? key, required this.user}) : super(key: key); 

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  late User _currentUser;
  late UserActions userActions;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadRecipes();
    userActions = UserActions(
      context: context, 
      currentUser: widget.user, 
      recipes: _recipes, 
      updateUser: updateUser,
      updateFilteredRecipes: updateFilteredRecipes,
    );
  }

  _loadRecipes() async {
    final allRecipes = await RecipeDB.instance.getAllRecipes();
    setState(() {
      userActions.recipes = allRecipes;
      userActions.filterRecipes('');
    });
  }

  void updateUser(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
  }

  void updateFilteredRecipes(List<Map<String, dynamic>> newFilteredRecipes) {
    setState(() {
      _filteredRecipes = newFilteredRecipes;
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
              onChanged: (query) {
                setState(() {
                  userActions.filterRecipes(query);
                });
              },
              decoration: InputDecoration(
                hintText: "Search recipes...",
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
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())), 
            icon: Icon(Icons.logout, color: Colors.white)
          ),
        ],
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
                final isFavorite = _currentUser.favorites.contains(recipe['id'].toString());
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
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 2.0,
                        ),
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
                                const Icon(
                                  Icons.restaurant_menu,
                                  size: 45.0,
                                  color: Colors.white,
                                ),
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
                              onPressed: () {
                                if (isFavorite) {
                                  setState(() {
                                    userActions.removeFromFavorites(recipe);
                                  });
                                } else {
                                  setState(() {
                                    userActions.addToFavorites(recipe);
                                  });
                                }
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(
                                Icons.access_alarm_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                String? selectedDate = await userActions.selectDate();
                                if (selectedDate != null) {
                                  setState(() {
                                    userActions.addToTodorecipes(recipe['id'].toString(), selectedDate);
                                  });
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
      bottomNavigationBar: MyNavBar(user: _currentUser, currentpage: "Search"),
    );
  }
}