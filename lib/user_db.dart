 import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'user.dart'; 

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

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    Map<String, dynamic> userMap = user.toMap();
    userMap['password'] = _hashPassword(user.password);
    return await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    return List.generate(userMaps.length, (i) {
      return User.fromMap(userMaps[i]);
    });
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final String hashedPassword = _hashPassword(password);
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
      limit: 1,
    );
    if (result.isNotEmpty) {
      print('Found user');
      return User.fromMap(result.first);
    }
    print('Did not find user');
    return null;
  }

  Future<User?> retrieveUser(User user) async {
    final db = await database;
    final String hashedPassword = _hashPassword(user.password);
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [user.email, hashedPassword],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    Map<String, dynamic> values = user.toMap();

    return await db.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> closeDatabase() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
