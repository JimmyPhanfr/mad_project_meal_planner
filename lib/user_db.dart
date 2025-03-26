import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserDB {
  static final UserDB _instance = UserDB._internal();
  factory UserDB() => _instance;
  UserDB._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE users ADD COLUMN favorites TEXT NOT NULL DEFAULT '[]'");
          await db.execute("ALTER TABLE users ADD COLUMN groceries TEXT NOT NULL DEFAULT '[]'");
          await db.execute("ALTER TABLE users ADD COLUMN todorecipes TEXT NOT NULL DEFAULT '[]'");
        }
      },
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            date_of_birth TEXT NOT NULL,
            password TEXT NOT NULL,
            favorites TEXT NOT NULL DEFAULT '[]',
            groceries TEXT NOT NULL DEFAULT '[]',
            todorecipes TEXT NOT NULL DEFAULT '[]'
          )''',
        );
      },
    );
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
