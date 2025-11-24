import 'package:flutter/material.dart';
import 'package:smp/models/category.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/music.dart';
import 'package:smp/models/song.dart';
import '../models/user_profile.dart';
import '../services/apiService.dart';

List<Song> songs = [];

final List<Music> categories = [
  Music(
      category:
          Category(name: "Top Songs1", imageURL: "assets/images/LOGO.png"),
      songs: []),
  Music(
      category: Category(name: "Hot Mix", imageURL: "assets/images/LOGO.png"),
      songs: []),
  Music(
      category:
          Category(name: "Romantic Mix", imageURL: "assets/images/LOGO.png"),
      songs: []),
];

// ignore: non_constant_identifier_names
final List<Category> HSSections = [
  Category(name: 'Top Songs', imageURL: 'https://cdn1.suno.ai/32f56318.webp'),
  Category(name: 'Hot Mix', imageURL: 'https://cdn1.suno.ai/32f56318.webp'),
  Category(
      name: 'Romantic Mix', imageURL: 'https://cdn1.suno.ai/32f56318.webp'),
  Category(
      name: 'Latest Hits',
      imageURL:
          'https://is3-ssl.mzstatic.com/image/thumb/Purple122/v4/2a/0a/13/2a0a1378-2d71-5373-040c-4c790dfe0ac8/source/256x256bb.jpg'),
];

final Map<String, Mood> moods = {
  "Happy": Mood("Happy", Icons.emoji_emotions, Colors.orange),
  "Sad": Mood("Sad", Icons.sentiment_dissatisfied, Colors.blue),
  "Chill": Mood("Chill", Icons.self_improvement, Colors.teal),
  "Energetic": Mood("Energetic", Icons.bolt, Colors.red),
  "Romantic": Mood("Romantic", Icons.favorite, Colors.pink),
  "Angry": Mood("Angry", Icons.mood_bad, Colors.deepOrange),
  "Peaceful": Mood("Peaceful", Icons.spa, Colors.green),
  "Party": Mood("Party", Icons.music_note, Colors.purple),
  "Motivational": Mood("Motivational", Icons.fitness_center, Colors.indigo),
  "Nostalgic": Mood("Nostalgic", Icons.history, Colors.brown),
};

final List<Mood> moodss = [
  Mood("Happy", Icons.emoji_emotions, Colors.orange),
  Mood("Sad", Icons.sentiment_dissatisfied, Colors.blue),
  Mood("Chill", Icons.self_improvement, Colors.teal),
  Mood("Energetic", Icons.bolt, Colors.red),
  Mood("Romantic", Icons.favorite, Colors.pink),
  Mood("Angry", Icons.mood_bad, Colors.deepOrange),
  Mood("Peaceful", Icons.spa, Colors.green),
  Mood("Party", Icons.music_note, Colors.purple),
  Mood("Motivational", Icons.fitness_center, Colors.indigo),
  Mood("Nostalgic", Icons.history, Colors.brown),
];

// final fakeUserProfile = UserProfile(
//   uid: "user_12345",
//   name: "Marina",
//   email: "marina@example.com",
//   photoUrl: null, // or add a real URL
//   bio: "Music lover 🎵 Developer 💻 Coffee addict ☕",
//   favoriteMood: moods[0], // Happy
//   playlists: categories,
// );
final Map<String, UserProfile> users = {
  "marina@gmail.com": UserProfile(
    uid: "user_12345",
    name: "Marina",
    email: "marina@gmail.com",
    photoUrl: null, // or add a real URL
    bio: "Music lover 🎵 Developer 💻 Coffee addict ☕",
    favoriteMood: moodss[0], // Happy
    playlists: categories,
  )
};
