import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/screens/profile_screen.dart';
import 'package:smp/widgets/home_screen/category_title.dart';
import 'package:smp/widgets/home_screen/grid.dart';

class HomeScreen extends StatelessWidget {
  final String? mood;
  const HomeScreen({super.key, this.mood});

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    final name = getUserName();

    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }

    return "${mood != null ? capitalize(mood!) + ' ' : ''}$greeting, $name";
  }

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "User";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return capitalize(user.displayName!);
    }
    if (user.email != null && user.email!.contains("@")) {
      return capitalize(user.email!.split('@').first);
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          getGreeting(),
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (final item in HSSections)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTitle(item.name),
                  SizedBox(
                    height: 200,
                    child: Card(
                      child: Grid(
                        items: categories,
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
