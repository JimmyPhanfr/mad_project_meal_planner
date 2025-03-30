import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mealprep/navbar.dart';
import 'user.dart';
import 'user_db.dart';
import 'login_page.dart';

class GroceriesPage extends StatefulWidget {
  final User user;

  const GroceriesPage({Key? key, required this.user}) : super(key: key);

  @override
  _GroceriesPageState createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
  late Map<String, int> _groceries;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _groceries = Map.from(widget.user.groceries);
    _currentUser = widget.user;
  }

  Future<void> _markAsBought(String item) async {
    setState(() {
      _groceries.remove(item);
    });

    User updatedUser = widget.user.copyWith(groceries: _groceries);
    await UserDB().updateUser(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries', style: TextStyle(color: Colors.white),),
        centerTitle: true,
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
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: _groceries.isEmpty
                ? const Center(
                    child: Text(
                      'No groceries left!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _groceries.length,
                    itemBuilder: (context, index) {
                      final item = _groceries.keys.elementAt(index);
                      final quantity = _groceries[item]!;

                      return ListTile(
                        title: Text(
                          '$item (x$quantity)',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_box_outline_blank, color: Colors.white),
                          onPressed: () => _markAsBought(item),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],  
      ),  
      bottomNavigationBar: MyNavBar(user: _currentUser, currentpage: "Grocery"),
    );
  }
}
