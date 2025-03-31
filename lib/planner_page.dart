import 'package:mealprep/navbar.dart';
import 'recipe_db.dart';
//import 'user_db.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';
import 'logout_confirm.dart';
import 'user_actions.dart';

class PlannerPage extends StatefulWidget {
  User user;

  PlannerPage({super.key, required this.user});

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late List<Map<String, String>> usertodoRecipes = widget.user.todorecipes; //retrieves the list of todorecipes from the user data, retrieving the recipeId and date
  late List<String> todoRecipeIds = usertodoRecipes.map((usertodoRecipes) => usertodoRecipes['recipeId']!).toList(); //retrieves the list of recipeIds from the user's todorecipe list
  late List<Map<String, dynamic>> todoRecipes = []; //list of the recipes in the todolist
  List<Map<String, dynamic>> _filteredRecipes = [];
  List<Map<String, dynamic>> favoriteRecipes =[];
  List<String> favoriteRecipeIds = [];
  late UserActions userActions;

  @override
  void initState() {
    super.initState();
    usertodoRecipes.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a['date']!).compareTo(DateFormat('yyyy-MM-dd').parse(b['date']!))); //sorts the list of recipes according to their dates, earliest to latest
    _loadRecipes();
    userActions = UserActions(
      context: context, 
      currentUser: widget.user, 
      recipes: todoRecipes, 
      updateUser: updateUser,
      updateFilteredRecipes: updateFilteredRecipes,
    );
    favoriteRecipeIds = List<String>.from(widget.user.favorites);
  }

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
      widget.user = updatedUser;
    });
  }
  
  //updates the loaded list of filtered recipes for this page when a search is done
  void updateFilteredRecipes(List<Map<String, dynamic>> newFilteredRecipes) {
    setState(() {
      _filteredRecipes = newFilteredRecipes;
    });
  }

  //responsible for properly updating favorite status in parent widget
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
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: usertodoRecipes.length,
                itemBuilder: (context, index) {
                  String recipeId = usertodoRecipes[index]['recipeId']!;
                  String date = usertodoRecipes[index]['date']!;
                  Map<String, dynamic> recipe = todoRecipes.firstWhere( //finds the recipe corresponding to the recipeid
                    (recipe) => recipe['id'].toString() == recipeId,
                    orElse: () => {'title': 'Unknown Recipe'},
                  );
                  return Dismissible( //swipe to remove recipe form the list
                    key: Key(recipeId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        userActions.removeFromTodorecipes(recipeId, date); //properly updates user data
                        usertodoRecipes.removeAt(index); //removes from local list
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text("Recipe: ${recipe['title']}"),
                        subtitle: Text("Date: ${usertodoRecipes[index]['date']}"),
                        onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      id: int.parse(recipeId),
                                      title: recipe['title'],
                                      ingredients: recipe['ingredients'],
                                      instructions: recipe['instructions'],
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavBar(user: widget.user, currentpage: "Planner")
    );
  }
}




