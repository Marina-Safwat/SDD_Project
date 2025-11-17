import 'package:flutter/material.dart';
import 'package:smp/screens/mood_song_list.dart';

class MoodScreen extends StatelessWidget {
  final List<Map<String, dynamic>> moods = [
    {"name": "Happy", "icon": Icons.emoji_emotions, "color": Colors.orange},
    {"name": "Sad", "icon": Icons.sentiment_dissatisfied, "color": Colors.blue},
    {"name": "Chill", "icon": Icons.self_improvement, "color": Colors.teal},
    {"name": "Energetic", "icon": Icons.bolt, "color": Colors.red},
    {"name": "Romantic", "icon": Icons.favorite, "color": Colors.pink},
    {"name": "Angry", "icon": Icons.mood_bad, "color": Colors.deepOrange},
    {"name": "Peaceful", "icon": Icons.spa, "color": Colors.green},
    {"name": "Party", "icon": Icons.music_note, "color": Colors.purple},
    {
      "name": "Motivational",
      "icon": Icons.fitness_center,
      "color": Colors.indigo
    },
    {"name": "Nostalgic", "icon": Icons.history, "color": Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Mood"),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: moods.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final mood = moods[index]["name"];
          final icon = moods[index]["icon"];
          final color = moods[index]["color"];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoodSongList(mood: mood),
                ),
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 46),
                  SizedBox(height: 10),
                  Text(
                    mood,
                    style: TextStyle(
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
