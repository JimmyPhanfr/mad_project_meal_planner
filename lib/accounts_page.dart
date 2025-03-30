import 'package:mealprep/navbar.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'textbox.dart';
import 'accounts_edit_fields.dart';
import 'logout_confirm.dart';

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
        title: const Text('Profile', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => logout(context),
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
      bottomNavigationBar: MyNavBar(user: _currentUser, currentpage: "Accounts"),
    );
  }
}




