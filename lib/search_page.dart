import 'dart:convert';
import 'detail_page.dart';
import 'package:flutter/material.dart';
import 'recipe_db.dart';
import 'user_db.dart';
import 'user.dart';
//import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
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
    await RecipeDB.instance.populateDatabase(recipes);
    final allRecipes = await RecipeDB.instance.getAllRecipes();
    setState(() {
      //_recipes = allRecipes;
      //_filteredRecipes = allRecipes;
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
    );
  }
}

final List<Map<String, dynamic>> recipes = [
  {
    'id': 1,
    'title': 'Gyudon',
    'ingredients': jsonEncode([
      'soy sauce',
      'sugar',
      'mirin',
      'seasoned rice wine',
      'sake', 
      'rice wine',
      'dashi broth',
      'ginger',
      'onion',
      'thinly sliced beef',
      'eggs',
      'rice',
      'benishoga', 
      'pickled ginger',
      'green onion',
      'Shichimi togarashi'
    ]),
    'instructions': jsonEncode([
      'In a large skillet, combine soy sauce, sugar, mirin, sake, dashi, and ginger. Bring to a boil over high heat.',
      'Reduce heat to medium-high and add sliced onion. Cover and simmer for 1 minute.',
      'Remove ginger slices and add thinly sliced beef. Stir occasionally to cook evenly.',
      'After 4 minutes or when beef is 3/4 cooked, crack eggs into the skillet and cover for desired doneness.',
      'Serve over rice with pickled ginger, green onions, and shichimi to taste.'
    ]),
    'image' : 'assets/images/gyudon.webp',
    'tags' : jsonEncode(['beef', 'egg', 'rice', 'asian', 'japanese']),
  },
  {
    'id': 2,
    'title': 'Jamaican Oxtail',
    'ingredients': jsonEncode([ 
      'oxtail',
      'soy sauce',
      'Worcestershire sauce',
      'onion',
      'garlic',
      'browning sauce',
      'thyme',
      'scotch bonnet pepper',
      'carrots',
      'butter beans',
      'beef broth'
    ]),
    'instructions': jsonEncode([
      'Marinate oxtail with soy sauce, Worcestershire sauce, and seasonings for at least 1 hour.',
      'In a pot, brown oxtail on all sides, then add onions, garlic, and thyme.',
      'Add beef broth, carrots, and scotch bonnet pepper. Simmer for 2-3 hours until tender.',
      'Add butter beans and cook for another 15 minutes.',
      'Serve hot with rice and peas.'
    ]),
    'image' : 'assets/images/oxtail.jpg',
    'tags' : jsonEncode(['oxtail', 'jamaican', 'caribbean', 'beans']),
  },
  {
    'id': 3,
    'title': 'Jamaican Curry Chicken',
    'ingredients': jsonEncode([
      'Chicken',
      'Jamaican Curry Powder',
      'Allspice', 
      'adobo seasoning', 
      'turmeric', 
      'thyme', 
      'salt',
      'black pepper',
      'Onion', 
      'scotch bonnet pepper',
      'carrots', 
      'garlic', 
      'ginger', 
      'green onion', 
      'potatoes',
      'Coconut milk',
      'Olive oil',
      'hot sauce',
    ]),
    'instructions': jsonEncode([
      'Cut up the chicken into smaller pieces and add to a large bowl.',
      'Season the Chicken. Rub the chicken pieces with 2 tablespoons Jamaican curry powder, adobo seasoning, allspice, dried thyme, turmeric, and salt and pepper to taste.',
      'Cook the Vegetables. Heat the oil in a large pot or Dutch oven over medium heat or medium-high heat. Add the onion and peppers, and cook them down 5 minutes to soften.',
      '"Burn the Curry". Add the garlic, ginger, and 2 tablespoons Jamaican curry powder. Cook for 2 minutes in the oil to let the seasoning bloom.',
      'This is called "Burning the Curry", which isn\'t actually burning it, but cooking out the raw seasoning flavor.',
      'Brown the Chicken. Add the chicken and cook for 10 minutes to brown all sides, flipping half way through.',
      'NOTE that the chicken may release liquid, which you can keep in the pan for simmering, though you may want to adjust how much liquid you add later.',
      'Liquids and Potatoes. Stir in the coconut milk or chicken broth, potatoes, and carrots. Taste and adjust with salt, pepper and hot sauce to your personal tastes.',
      'Add a few sprigs of fresh thyme here if you\'d like.',
      'Cover and Simmer. Cover the curry and reduce the heat. Simmer for 20 to 30 minutes, or until the vegetables are done and the chicken is tender and cooked through.',
      'It should measure 165 degrees F internal when measured with a meat thermometer.',
      'Serve! I like to garnish mine with fresh chopped parsley and red pepper flakes.',
      'Boom! Done! Jamaican curry chicken is ready to serve! Looks wonderful, doesn\'t it? I\'m sure your kitchen smells awesome.',
    ]),
    'image' : 'assets/images/curry.jpg',
    'tags' : jsonEncode(['chicken', 'curry', 'potato', 'jamaican', 'caribbean']),
  },
  {
    'id': 4,
    'title': 'Katsudon',
    'ingredients': jsonEncode([
      'dashi',
      'soy sauce',
      'sake',
      'sugar',
      'mirin',
      'yellow onion',
      'pork cutlet',
      'eggs',
      'green onions',
      'white rice',
    ]),
    'instructions': jsonEncode([
      'Combine dashi, soy sauce, sake, sugar, and mirin in a small saucepan or donburi pan and bring to a simmer over medium heat.',
      'If using onion, add to broth and simmer until tender, about 5 minutes.',
      'Add sliced fried cutlet and let simmer for 1 minute.',
      'Meanwhile, beat together eggs and scallions in a small bowl. Pour egg mixture on top of cutlet and around broth.',
      'Cover and cook until eggs are as set as you\'d like them, about 1 minute for very soft or 2 minutes for medium.',
      'Slide broth, egg, and chicken out on top of a bowl of rice. Sprinkle with scallions and serve.',
    ]),
    'image' : 'assets/images/katsudon.jpg',
    'tags' : jsonEncode(['chicken', 'egg', 'rice', 'asian', 'japanese']),
  },
  {
    'id': 5,
    'title': 'Pasta Carbonara',
    'ingredients': jsonEncode([
      'Bacon',
      'Water',
      'Garlic',
      'Linguine',
      'Parmesan',
      'Eggs',
      'Salt',
      'Pepper',
      'Fresh Parsley',
    ]),
    'instructions': jsonEncode([
      'Add bacon and water to a skillet and bring to a simmer.',
      'Continue simmering until water is evaporated, then continue to cook the bacon until crispy.',
      'Remove bacon from pan and reserve the drippings.',
      'Saute garlic in that same skillet until golden brown, then add to a bowl with 1 tablespoon bacon fat, eggs, egg yolk, Parmesan and pepper. Mix well.',
      'Meanwhile, cook the spaghetti or linguine pasta until al dente. Once cooked, drain pasta and reserve 1 cup of the cooking water.',
      'Slowly pour the hot cooking water into the egg mixture. Then pour over the hot pasta and toss to coat. Add crumbled bacon.',
      'Let pasta rest for a few minutes, tossing frequently until the carbonara sauce thickens. Serve immediately with a sprinkle of fresh parsley.',
    ]),
    'image' : 'assets/images/carbonara.jpg',
    'tags' : jsonEncode(['bacon', 'egg', 'pasta', 'parmesan', 'pork']),
  },
  {
    'id' : 6,
    'title' : 'Lasagna',
    'ingredients': jsonEncode([
      'yellow onion',
      'olive oil',
      'ground beef',
      'salt',
      'black pepper',
      'marinara sauce',
      'mozzarella cheese',
      'lasagna noodles',
      'ricotta cheese',
    ]),
    'instructions': jsonEncode([
      'Heat the oven to 400ºF. Arrange a rack in the middle of the oven and heat the oven to 400°F.',
      'Brown the beef and onion. Finely chop 1 medium yellow onion. Heat 1 tablespoon olive oil in a 12-inch or larger regular or cast iron skillet over medium-high heat until shimmering. Add the onion, 1 pound lean ground beef, 1/2 teaspoon kosher salt, and 1/4 teaspoon freshly ground black pepper, and cook, breaking the beef up into small pieces with a wooden spoon, until the beef is cooked through, 6 to 8 minutes. Remove from the heat and let cool for 5 minutes.',
      'Prepare the baking dish and assemble the meat sauce. Open 1 (24 to 25-ounce) jar marinara sauce (3 cups). Spread a thin layer of the sauce in the bottom of a 9x13-inch baking dish. Stir the remaining sauce into the ground beef mixture.',
      'Begin layering the lasagna. Shred 12 ounces low-moisture mozzarella cheese if needed (3 cups). Place 5 lasagna noodles in the baking dish, breaking them if needed to create a single layer (it’s OK if the noodles overlap slightly). Dollop and spread 1 cup of the ricotta cheese over the noodles. Dollop and spread about 1 1/2 cups of the meat sauce on the ricotta, then sprinkle with 1 cup of the mozzarella.',
      'Continue layering the lasagna. Arrange 5 more noodles over the mozzarella, followed by 1 cup of the ricotta cheese, 1 1/2 cups of the meat sauce, and 1 cup of the mozzarella. Top with a final layer of 5 noodles and the remaining sauce, spreading the sauce thin so that it almost completely covers the noodles. (Reserve the remaining 1 cup mozzarella for the end of baking.) Cover the dish tightly with aluminum foil.',
      'Bake the lasagna for 1 hour. Bake for 1 hour. Check to make sure the noodles are done by poking the lasagna with a knife; the knife should slide easily through all the layers. If it doesn\'t, cover and cook for 15 minutes more.',
      'Sprinkle with the remaining mozzarella and finish baking. Uncover the lasagna and sprinkle with the remaining 1 cup mozzarella. Bake uncovered until the mozzarella is melted and lightly browned, and the sauce is bubbling, 8 to 10 minutes more.Let pasta rest for a few minutes, tossing frequently until the carbonara sauce thickens. Serve immediately with a sprinkle of fresh parsley.',
      'Cool the lasagna for 15 minutes. Let the lasagna cool on a wire rack for at least 15 minutes before serving.',
    ]),
    'image' : 'assets/images/lasagna.webp',
    'tags' : jsonEncode(['cheese', 'beef', 'pasta', 'parmesan', 'marinara', 'mozarella cheese', 'ricotta cheese', 'lasagna']),
  },
];