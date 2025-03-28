import 'dart:convert';
import 'package:flutter/material.dart';
import 'user.dart';
import 'user_db.dart';

class GroceriesPage extends StatefulWidget {
  final User user;

  const GroceriesPage({Key? key, required this.user}) : super(key: key);

  @override
  _GroceriesPageState createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
  late Map<String, int> _groceries;

  @override
  void initState() {
    super.initState();
    _groceries = Map.from(widget.user.groceries);
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
      appBar: AppBar(title: const Text('Groceries')),
      body: _groceries.isEmpty
          ? const Center(child: Text('No groceries left!'))
          : ListView.builder(
              itemCount: _groceries.length,
              itemBuilder: (context, index) {
                final item = _groceries.keys.elementAt(index);
                final quantity = _groceries[item]!;

                return ListTile(
                  title: Text('$item (x$quantity)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _markAsBought(item),
                  ),
                );
              },
            ),
    );
  }
}
