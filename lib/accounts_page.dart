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

import 'textbox.dart';
import 'accounts_edit_fields.dart';

class AccountsPage extends StatefulWidget {
  final User user;

  const AccountsPage({Key? key, required this.user}) : super(key: key);

  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late User _currentUser;
  // DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
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
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("My Details:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
                  MyTextBox(
                    text: _currentUser.name, 
                    sectionName: "Name",
                    onPressed: () {
                      setState(() {
                        editNameField(context, _currentUser);
                        _currentUser = widget.user;
                      });
                    }
                  ),
                  MyTextBox(
                    text: _currentUser.email, 
                    sectionName: "Email",
                    // onPressed: () => editEmailField(context, _currentUser),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Email not allowed to be changed."),
                        ),
                      );
                    },
                  ),
                  MyTextBox(
                    text: _currentUser.dateOfBirth, 
                    sectionName: "Date of Birth",
                    onPressed: () => editDOBField(context, _currentUser),
                  ),
                  MyTextBox(
                    text: "User password hidden for security.",
                    sectionName: "Password",
                    onPressed: () => editPasswordField(context, _currentUser),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 6),
                    child: Text("May have to re-login to see changes.", style: TextStyle(fontSize: 16),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60.0,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Container(
              height: 40,
              width: 40,
              decoration: new BoxDecoration(
                color: Colors.lightGreenAccent,
                borderRadius: new BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountsPage(user: _currentUser)),);
                },
                icon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




