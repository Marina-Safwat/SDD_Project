import 'package:flutter/material.dart';
import 'package:smp/models/category.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/music.dart';
import 'package:smp/models/song.dart';
import 'package:smp/models/user_profile.dart';

List<Song> songs = [
  Song(
      'Feather',
      'Sabrina Carpenter',
      'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
      'Sabrina',
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
      'happy'),
  Song(
      'test',
      'Sabrina Carpenter',
      'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
      'tester',
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
      'happy'),
  Song(
      'Feather',
      'Sabrina Carpenter',
      'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
      'Sabrina',
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
      'happy'),
];

List<Music> categories = [
  Music(Category("Top Songs1", "assets/images/LOGO.png"), songs),
  Music(Category("Top Songs2", "assets/images/LOGO.png"), songs),
  Music(Category("Top Songs3", "assets/images/LOGO.png"), songs),
  Music(Category("Top Songs4", "assets/images/LOGO.png"), songs),
  Music(Category("Top Songs5", "assets/images/LOGO.png"), songs),
  Music(Category("Top Songs6", "assets/images/LOGO.png"), songs),
];

List<Category> HSSections = [
  Category('Top Songs', 'https://cdn1.suno.ai/32f56318.webp'),
  Category('Hot Mix', 'https://cdn1.suno.ai/32f56318.webp'),
  Category('Romantic Mix', 'https://cdn1.suno.ai/32f56318.webp'),
  Category('Latest Hits',
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
    favoriteMood: moodss[0]!, // Happy
    playlists: categories,
  )
};
