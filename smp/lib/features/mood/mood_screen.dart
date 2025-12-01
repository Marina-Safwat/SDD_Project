import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/features/tabs_screen.dart';

/// Screen shown after login/sign-up where the user selects their current mood.
///
/// Once a mood is selected, the app navigates to [TabsScreen] and passes
/// the chosen mood, which can be used to personalize the home experience.
class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('How are you feeling now?'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: moodss.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final mood = moodss[index];
          final name = mood.name;
          final icon = mood.icon;
          final color = mood.color;

          return GestureDetector(
            onTap: () {
              // If you want to persist favorite mood per user in the future:
              // users[FirebaseAuth.instance.currentUser!.email]!.favoriteMood = mood;

              // ✅ After picking a mood, go to the main screen and
              // remove MoodScreen from the back stack.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TabsScreen(mood: mood),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 46),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
