import 'package:mealprep/navbar.dart';
import 'login_page.dart';
import 'recipe_db.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'detail_page.dart';
import 'user_actions.dart';

/*
Page that lists the user's list of favorited recipes. User can remove the recipe from the list of favorites and add the recipe to their planner list
*/

class FavoritePage extends StatefulWidget {
  User currentUser;

  FavoritePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<String> favoriteRecipeIds;
  List<Map<String, dynamic>> favoriteRecipes = []; 
  List<Map<String, dynamic>> _filteredRecipes = [];
  late UserActions userActions;


  @override
  void initState() {
    super.initState();
    favoriteRecipeIds = List<String>.from(widget.currentUser.favorites);
    _loadRecipes();
    userActions = UserActions(
      context: context, 
      currentUser: widget.currentUser, 
      recipes: favoriteRecipes, 
      updateUser: updateUser,
      updateFilteredRecipes: updateFilteredRecipes,
    );
    userActions.filterRecipes('');
  }

  //loads the list of the user's favorite recipes
  _loadRecipes() async {
    favoriteRecipes = await RecipeDB.instance.getRecipes(
      favoriteRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
    setState(() {
      userActions.recipes = favoriteRecipes;
      userActions.filterRecipes('');
    });
  }

  //updates the user information for this page when a user action is done
  void updateUser(User updatedUser) {
    setState(() {
      widget.currentUser = updatedUser;
    });
  }
  
  //updates the loaded list of filtered recipes for this page when a search is done
  void updateFilteredRecipes(List<Map<String, dynamic>> newFilteredRecipes) {
    setState(() {
      _filteredRecipes = newFilteredRecipes;
    });
  }

  void updateFavoriteStatus(int recipeId, bool isFavorited) async {
    List<String> updatedFavoriteRecipeIds = List<String>.from(widget.currentUser.favorites);
    List<Map<String, dynamic>> updatedFavoriteRecipes = await RecipeDB.instance.getRecipes(
      updatedFavoriteRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
    setState(() {
      favoriteRecipeIds = updatedFavoriteRecipeIds;
    favoriteRecipes = updatedFavoriteRecipes;
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
                  //searches the list of recipes for a certain query
                  userActions.filterRecipes(query);
                });
              },
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
              itemBuilder: (context, index) { //lists all the filtered recipes, default an empty string to list all recipes, is in a tile view
                final recipe = _filteredRecipes[index];
                final isFavorite = favoriteRecipeIds.contains(recipe['id'].toString()); //keeps track of which recipes have been favorited by the user, to show the appropriate icon and appropriate action when button pressed
                return GestureDetector(
                  onTap: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          id: recipe['id'],
                          title: recipe['title'],
                          ingredientsJson: recipe['ingredients'],
                          instructionsJson: recipe['instructions'],
                          image: recipe['image'],
                          user: widget.currentUser,
                          onFavoriteChanged: updateFavoriteStatus,
                          updateUser: updateUser,
                          updateFilteredRecipes: updateFilteredRecipes,
                        ),
                      ),
                    );
                    if (updatedUser != null) {
                      setState(() {
                        widget.currentUser = updatedUser;
                        favoriteRecipeIds = List<String>.from(updatedUser.favorites);
                        _filteredRecipes = _filteredRecipes
                            .where((recipe) => favoriteRecipeIds.contains(recipe['id'].toString()))
                            .toList();
                      });
                    }
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
                              //favorite button icon, when pressed removes the favorited recipe
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () { 
                                setState(() {
                                    userActions.removeFromFavorites(recipe);
                                    favoriteRecipeIds = List<String>.from(widget.currentUser.favorites);
                                    favoriteRecipes = favoriteRecipes.where((r) => r['id'] != recipe['id']).toList();
                                    _filteredRecipes = _filteredRecipes.where((r) => r['id'] != recipe['id']).toList();
                                    userActions.recipes = favoriteRecipes;
                                });
                              }
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton( //button to add a recipe to the planner
                              icon: const Icon(Icons.access_alarm_outlined, color: Colors.white),
                              onPressed: () async {
                                String? selectedDate = await userActions.selectDate(); //for user to select a date for the recipe
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
      bottomNavigationBar: MyNavBar(user: widget.currentUser, currentpage: "Favorite"),
    );
  }
}




