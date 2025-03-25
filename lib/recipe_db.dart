import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe);
  }

  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await instance.database;
    return await db.query('recipes');
  }

  Future<bool> isDatabasePopulated() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM recipes'));
    return (count ?? 0) > 0;
  }

  Future<void> populateDatabase(List<Map<String, dynamic>> recipes) async {
    final db = await instance.database;
    if (await isDatabasePopulated()) {
      print('Database already populated. Skipping insertion.');
      return;
    }
    Batch batch = db.batch();
    for (var recipe in recipes) {
      batch.insert('recipes', recipe);
    }
    await batch.commit(noResult: true);
    print('Database populated successfully!');
  }

  Future<int> updateRecipe(int id, Map<String, dynamic> recipe) async {
    final db = await instance.database;
    return await db.update('recipes', recipe, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

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
}
