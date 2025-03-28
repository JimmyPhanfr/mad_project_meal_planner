import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String dateOfBirth;
  final String password;
  final List<String> favorites;
  final Map<String, int> groceries;
  final List<Map<String, String>> todorecipes; 

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.password,
    required this.favorites,
    required this.groceries,
    required this.todorecipes,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'password': password,
      'favorites': jsonEncode(favorites),
      'groceries': jsonEncode(groceries),
      'todorecipes': jsonEncode(todorecipes),
    };
    if (id != 0) {
      map['id'] = id.toString();
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      dateOfBirth: map['date_of_birth'],
      password: map['password'],
      favorites: List<String>.from(jsonDecode(map['favorites'])),
      groceries: Map<String, int>.from(jsonDecode(map['groceries'])),
      todorecipes: List<Map<String, String>>.from(
        jsonDecode(map['todorecipes']).map((item) => Map<String, String>.from(item)),
      ),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? dateOfBirth,
    String? password,
    List<String>? favorites,
    Map<String, int>? groceries,
    List<Map<String, String>>? todorecipes,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      password: password ?? this.password,
      favorites: favorites ?? this.favorites,
      groceries: groceries ?? this.groceries,
      todorecipes: todorecipes ?? this.todorecipes,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, dateOfBirth: $dateOfBirth}';
  }
}
