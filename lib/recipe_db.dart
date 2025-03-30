import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*
Recipe Database class: Does population of database, searching for recipes, insertion, deletion and update of recipes (these are mainly for admin purposes)
Lists in Recipes are stored in JSONencoded format and retrieved properly using JSONdecode
*/
class RecipeDB {
  static final RecipeDB instance = RecipeDB._init();
  static Database? _database;

  RecipeDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        image TEXT NOT NULL,
        tags TEXT NOT NULL
      )
    ''');
  }

  //inserts a recipe to the database, assumes the lists in the recipes are already JSONencoded
  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe);
  }

  //retrieves all the recipes from the database
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await instance.database;
    return await db.query('recipes');
  }

  //retrieves all the recipes that match the list of recipeIds
  Future<List<Map<String, dynamic>>> getRecipes(List<int> recipeIds) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> recipes = await db.query(
      'recipes',
      where: 'id IN (${List.filled(recipeIds.length, '?').join(',')})',
      whereArgs: recipeIds,
    );
    return recipes;
  }

  //retrieveslength of the recipe database, ie how many recipes are in the database
  Future<int> getDatabaseRecipeCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM recipes')) ?? 0;
  }

  //populates the database using a list of recipes
  Future<void> populateDatabase(List<Map<String, dynamic>> recipes) async {
    final db = await instance.database;
    final count = await getDatabaseRecipeCount();

    if (count >= recipes.length) {
      print('Database already has sufficient data. Skipping insertion.');
      return;
    }
  
    await db.transaction((txn) async {
      await txn.delete('recipes');
      Batch batch = txn.batch();
      for (var recipe in recipes) {
        batch.insert('recipes', recipe);
      }
      await batch.commit(noResult: true);
    });
    print('Database repopulated successfully!');
  }

  //updates a recipe, must be given the recipe's corresponding id, the recipe given must have it's list already JSONencoded
  Future<int> updateRecipe(int id, Map<String, dynamic> recipe) async {
    final db = await instance.database;
    return await db.update('recipes', recipe, where: 'id = ?', whereArgs: [id]);
  }

  //deletes a recipe, must be given the recipe's corresponding id
  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
/*
These functions are not really used as the JSONencoding of recipes is manually done in the original list of recipes
  //converts a recipe to the appropriate format with its' lists JSONencoded
  Map<String, dynamic> recipeToMap({
    required int id,
    required String title,
    required List<String> ingredients,
    required List<String> instructions,
    required String image,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'title': title,
      'ingredients': jsonEncode(ingredients),
      'instructions': jsonEncode(instructions),
      'image': image,
      'tags': jsonEncode(tags),
    };
  }

  //converts a recipe to the appropriate format with its' lists JSONencoded, but does not assign an id number, so when the recipe is inserted to the db, it's auto assigned an id number
  Map<String, dynamic> insertRecipeModel({
    required String title,
    required List<String> ingredients,
    required List<String> instructions,
    required String image,
    required List<String> tags,
  }) {
    return {
      'title': title,
      'ingredients': jsonEncode(ingredients),
      'instructions': jsonEncode(instructions),
      'image': image,
      'tags': jsonEncode(tags),
    };
  }

*/
}
