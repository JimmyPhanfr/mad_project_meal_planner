import 'package:mealprep/navbar.dart';
import 'detail_page.dart';
import 'package:flutter/material.dart';
import 'recipe_db.dart';
import 'user.dart';
import 'user_actions.dart';
import 'logout_confirm.dart';

class SearchPage extends StatefulWidget {
  User user;
  SearchPage({super.key, required this.user}); 

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _filteredRecipes = [];
  List<Map<String, dynamic>> favoriteRecipes =[];
  List<String> favoriteRecipeIds = [];
  late UserActions userActions;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    userActions = UserActions(
      context: context, 
      currentUser: widget.user, 
      recipes: [], 
      updateUser: updateUser,
      updateFilteredRecipes: updateFilteredRecipes,
    );
    favoriteRecipeIds = List<String>.from(widget.user.favorites);
  }

  //loads the list of all recipes from the database
  _loadRecipes() async {
    final allRecipes = await RecipeDB.instance.getAllRecipes(); //keeps track of all the recipes
    setState(() {
      userActions.recipes = allRecipes; 
      userActions.filterRecipes(''); //since the search page on default shows the list of filteredrecipes, this loads all the recipes into the filtered recipes
    });
    favoriteRecipes = await RecipeDB.instance.getRecipes(
      favoriteRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
  }

  //updates the user information for this page when a user action is done
  void updateUser(User updatedUser) {
    setState(() {
      widget.user = updatedUser;
    });
  }

  //updates the loaded list of filtered recipes for this page when a search is done
  void updateFilteredRecipes(List<Map<String, dynamic>> newFilteredRecipes) {
    setState(() {
      _filteredRecipes = newFilteredRecipes;
    });
  }


  void updateFavoriteStatus(int recipeId, bool isFavorited) async {
    List<String> updatedFavoriteRecipeIds = List<String>.from(widget.user.favorites);
    List<Map<String, dynamic>> updatedFavoriteRecipes = await RecipeDB.instance.getRecipes(
      updatedFavoriteRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
    setState(() async {
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
            onPressed: () => logout(context), 
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
              itemBuilder: (context, index) { //lists all the recipes in a tile view
                final recipe = _filteredRecipes[index]; 
                final isFavorite = widget.user.favorites.contains(recipe['id'].toString()); //keeps track of which recipes have been favorited by the user, to show the appropriate icon and appropriate action when button pressed
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          id: recipe['id'],
                          title: recipe['title'],
                          ingredientsJson: recipe['ingredients'],
                          instructionsJson: recipe['instructions'],
                          image: recipe['image'],
                          user: widget.user,
                          onFavoriteChanged: updateFavoriteStatus,
                          updateUser: updateUser,
                          updateFilteredRecipes: updateFilteredRecipes,
                          recipes: _filteredRecipes,
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
                            child: IconButton( //button to add a recipe to the favorite list
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white, 
                              ),
                              onPressed: () {
                                if (isFavorite) {
                                  setState(() {
                                    //if the recipe is already favorited, removes the recipe
                                    userActions.removeFromFavorites(recipe);
                                  });
                                } else {
                                  setState(() {
                                    //if the recipe is not already favorited, then adds the recipe to the favorite list
                                    userActions.addToFavorites(recipe);
                                  });
                                }
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton( //button to add a recipe to the planner
                              icon: Icon(
                                Icons.access_alarm_outlined,
                                color: Colors.white,
                              ),
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
      bottomNavigationBar: MyNavBar(user: widget.user, currentpage: "Search"),
    );
  }
}