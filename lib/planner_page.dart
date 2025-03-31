import 'package:mealprep/navbar.dart';
import 'recipe_db.dart';
import 'user_db.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';
import 'logout_confirm.dart';
import 'user_actions.dart';

class PlannerPage extends StatefulWidget {
  User currentUser;

  PlannerPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  // DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late List<String> todoRecipeIds;
  List<Map<String, String>> todoRecipesAndDate = [];
  List<Map<String, dynamic>> todoRecipes = []; 
  List<String> todoDates = [];

  List<Map<String, dynamic>> _filteredRecipes = [];
  List<Map<String, dynamic>> favoriteRecipes =[];
  List<String> favoriteRecipeIds = [];
  late UserActions userActions;

  @override
  void initState() {
    super.initState();
    todoRecipesAndDate = List<Map<String, String>>.from(widget.currentUser.todorecipes);
    todoRecipeIds = todoRecipesAndDate.expand((map) => map.keys).toList();
    todoDates = todoRecipesAndDate.expand((map) => map.values).toList();
    _loadRecipes();
    userActions = UserActions(
      context: context, 
      currentUser: widget.currentUser, 
      recipes: todoRecipes, 
      updateUser: updateUser,
      updateFilteredRecipes: updateFilteredRecipes,
    );
    favoriteRecipeIds = List<String>.from(widget.currentUser.favorites);
    userActions.filterRecipes('');
  }

  // loads the list of the user's todo recipes
  _loadRecipes() async {
    todoRecipes = await RecipeDB.instance.getRecipes(
      todoRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
    setState(() {
      userActions.recipes = todoRecipes;
      userActions.filterRecipes('');
    });
    favoriteRecipes = await RecipeDB.instance.getRecipes(
      favoriteRecipeIds.map((e) => int.tryParse(e) ?? 0).toList()
    );
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
    setState(() async {
      favoriteRecipeIds = updatedFavoriteRecipeIds;
      favoriteRecipes = updatedFavoriteRecipes;
    });
  }

  // Future<String?> _selectDate(BuildContext context) async {
  //   DateTime? selectedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (selectedDate != null) {
  //     return DateFormat('yyyy-MM-dd').format(selectedDate);
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner', style: TextStyle(color: Colors.white),),
        centerTitle: true,
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
              itemCount: todoRecipesAndDate.length,
              itemBuilder: (context, index) {
                final recipe = todoRecipes[index];
                final isFavorite = widget.currentUser.favorites.contains(recipe['id'].toString()); //keeps track of which recipes have been favorited by the user, to show the appropriate icon and appropriate action when button pressed
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
      bottomNavigationBar: MyNavBar(user: widget.currentUser, currentpage: "Planner")
    );
  }
}




