import 'package:flutter/material.dart';
import 'user.dart';
// import 'home_page.dart';
import 'search_page.dart';
import 'planner_page.dart';
import 'accounts_page.dart';
import 'favorite_page.dart';
import 'groceries_page.dart';

class MyNavBar extends StatelessWidget {
  final User user;
  final String currentpage;

  const MyNavBar({
    super.key,
    required this.user,
    required this.currentpage
  });

  @override build(BuildContext context) {
    return Container(
        height: 60.0,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Container(
            //   height: 40,
            //   width: 40,
            //   decoration: BoxDecoration(
            //     color: currentpage == "Home" ? Colors.lightGreenAccent: null,
            //     borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
            //   ),
            //   child: IconButton(
            //     onPressed: () {
            //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: user)),);
            //     },
            //     icon: Icon(Icons.home),
            //   ),
            // ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentpage == "Favorite" ? Colors.lightGreenAccent: null,
                borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FavoritePage(currentUser: user)),);
                },
                icon: Icon(Icons.favorite),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentpage == "Search" ? Colors.lightGreenAccent: null,
                borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage(user: user)),);
                },
                icon: Icon(Icons.search),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentpage == "Planner" ? Colors.lightGreenAccent: null,
                borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlannerPage(user: user)),);
                },
                icon: Icon(Icons.list),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentpage == "Grocery" ? Colors.lightGreenAccent: null,
                borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GroceriesPage(user: user)),);
                },
                icon: Icon(Icons.shopping_basket_outlined),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentpage == "Accounts" ? Colors.lightGreenAccent: null,
                borderRadius: BorderRadius.all(Radius.elliptical(40, 40)),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountsPage(user: user)),);
                },
                icon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      );
  }
}