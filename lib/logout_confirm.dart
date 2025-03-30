import 'package:flutter/material.dart';
import 'login_page.dart';

Future<void> logout(BuildContext context) async {
  await showDialog(
    context: context,
    builder:(context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text("Logout?", style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All data has been saved.",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Are you sure you want to logout?",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
        actions: [
          // Cancel
          TextButton(
            child: Text("Return", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // Go to login page
          TextButton(
            child: Text("Logout", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout Successful')));
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ]
    ),
  );
}