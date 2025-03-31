// ignore_for_file: deprecated_member_use

import 'package:mealprep/navbar.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'textbox.dart';
import 'accounts_edit_fields.dart';
import 'logout_confirm.dart';

class AccountsPage extends StatefulWidget {
  User user;

  AccountsPage({super.key, required this.user});

  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
  }

  void updateUser(User updatedUser) {
    setState(() {
      widget.user = updatedUser;
    });
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
                    text: widget.user.name, 
                    sectionName: "Name",
                    onPressed: () {
                      setState(() {
                        editNameField(context, widget.user, updateUser);
                      });
                    }
                  ),
                  MyTextBox(
                    text: widget.user.email, 
                    sectionName: "Email",
                    onPressed: () => editEmailField(context, widget.user, updateUser),
                  ),
                  MyTextBox(
                    text: widget.user.dateOfBirth, 
                    sectionName: "Date of Birth",
                    onPressed: () => editDOBField(context, widget.user, updateUser),
                  ),
                  MyTextBox(
                    text: "User password hidden for security.",
                    sectionName: "Password",
                    onPressed: () => editPasswordField(context, widget.user, updateUser),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavBar(user: widget.user, currentpage: "Accounts"),
    );
  }
}




