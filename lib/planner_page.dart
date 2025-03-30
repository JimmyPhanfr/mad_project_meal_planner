import 'package:mealprep/navbar.dart';

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

class PlannerPage extends StatefulWidget {
  final User user;

  const PlannerPage({Key? key, required this.user}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
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
        title: Text("Planner"),
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
      bottomNavigationBar: MyNavBar(user: _currentUser, currentpage: "Planner")
    );
  }
}




