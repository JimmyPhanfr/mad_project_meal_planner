import 'recipe_db.dart';
import 'user_db.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';

import 'home_page.dart';
import 'favorite_page.dart';
import 'search_page.dart';
import 'planner_page.dart';
import 'accounts_page.dart';

class AccountsPage extends StatefulWidget {
  final User user;

  const AccountsPage({Key? key, required this.user}) : super(key: key);

  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late User _currentUser;
  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<String?> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accounts"),
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
        ],
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: _currentUser)),);
              },
              icon: Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FavoritePage(currentUser: _currentUser)),);
              },
              icon: Icon(Icons.favorite),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage(user: _currentUser)),);
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlannerPage(user: _currentUser)),);
              },
              icon: Icon(Icons.list),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountsPage(user: _currentUser)),);
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}




