import 'package:flutter/material.dart';

import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/models/user_profile.dart';

/// Demo songs used in some sample categories / testing.
final List<Song> songs = [
  Song(
    id: '145Feather',
    name: 'Feather',
    artists: ['Sabrina Carpenter'],
    image: 'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
    album: 'Sabrina',
    audioUrl:
        'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
    mood: 'happy',
  ),
  Song(
    id: '145test',
    name: 'test',
    artists: ['Sabrina Carpenter'],
    image: 'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
    album: 'tester',
    audioUrl:
        'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
    mood: 'happy',
  ),
  Song(
    id: '167Feather',
    name: 'Feather',
    artists: ['Sabrina Carpenter'],
    image: 'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
    album: 'Sabrina',
    audioUrl:
        'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
    mood: 'happy',
  ),
];

/// Map of moods by name (string key).
final Map<String, Mood> moods = {
  'Happy': Mood('Happy', Icons.emoji_emotions, Colors.orange),
  'Sad': Mood('Sad', Icons.sentiment_dissatisfied, Colors.blue),
  'Chill': Mood('Chill', Icons.self_improvement, Colors.teal),
  'Energetic': Mood('Energetic', Icons.bolt, Colors.red),
  'Romantic': Mood('Romantic', Icons.favorite, Colors.pink),
  'Angry': Mood('Angry', Icons.mood_bad, Colors.deepOrange),
  'Peaceful': Mood('Peaceful', Icons.spa, Colors.green),
  'Party': Mood('Party', Icons.music_note, Colors.purple),
  'Motivational': Mood('Motivational', Icons.fitness_center, Colors.indigo),
  'Nostalgic': Mood('Nostalgic', Icons.history, Colors.brown),
};

/// List of moods used throughout the app (MoodScreen, MoodHome, Profile, etc.).
final List<Mood> moodss = [
  Mood('Happy', Icons.emoji_emotions, Colors.orange),
  Mood('Sad', Icons.sentiment_dissatisfied, Colors.blue),
  Mood('Chill', Icons.self_improvement, Colors.teal),
  Mood('Energetic', Icons.bolt, Colors.red),
  Mood('Romantic', Icons.favorite, Colors.pink),
  Mood('Angry', Icons.mood_bad, Colors.deepOrange),
  Mood('Peaceful', Icons.spa, Colors.green),
  Mood('Party', Icons.music_note, Colors.purple),
  Mood('Motivational', Icons.fitness_center, Colors.indigo),
  Mood('Nostalgic', Icons.history, Colors.brown),
];

/// In-memory user profiles, keyed by email.
///
/// New users get added here on login/signup.
/// This initial entry is just a demo/default user.
final Map<String, UserProfile> users = {
  'marina@gmail.com': UserProfile(
    uid: 'user_12345',
    name: 'Marina',
    email: 'marina@gmail.com',
    photoUrl: null,
    bio: 'Music lover 🎵 Developer 💻 Coffee addict ☕',
    favoriteMood: moodss[0], // Happy
  ),
};

/// Test song used for debugging / demos.
final Song testSong = Song(
  id: 'test1',
  name: 'Test Track',
  artists: ['Test Artist'],
  album: 'Test Album',
  image: 'https://i.scdn.co/image/ab67616d0000b273e7cba28f132cd431cc87fe57',
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  mood: 'happy',
);

/// Another test song (Pixabay source).
final Song testSong1 = Song(
  id: '99',
  name: 'Every Morning',
  artists: ['Anton Vlasov'],
  album: 'Pixabay Album',
  image: 'https://i.scdn.co/image/ab67616d0000b273e7cba28f132cd431cc87fe57',
  audioUrl:
      'https://cdn.pixabay.com/download/audio/2022/03/15/audio_93c9573c64.mp3?filename=every-morning-133686.mp3',
  mood: 'happy',
);
