import 'package:flutter/material.dart';
import 'package:smp/screens/home.dart';
import 'package:smp/screens/search.dart';
import 'package:smp/screens/yourLibrary.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Tabs = [Home(), Search(), Library()];
  int currentTabIndex = 0;
  // UIDesign code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (currentIndex) {
          print("current Index is $currentIndex ");
          setState(() {
            currentTabIndex = currentIndex;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.white), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add, color: Colors.white),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
