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

final Song testSong0 = Song(
  id: '99',
  name: 'Every Morning',
  artists: ['Anton Vlasov'],
  album: 'Pixabay Album',
  image: 'https://i.scdn.co/image/ab67616d0000b273e7cba28f132cd431cc87fe57',
  audioUrl:
      'https://cdn.pixabay.com/download/audio/2022/03/15/audio_93c9573c64.mp3?filename=every-morning-133686.mp3',
  mood: 'happy',
);

final Song testSong1 = Song(
  id: '4cba89f1-1a8a-3f33-b3ac-d88bcad8b996',
  name: 'Happy (From "Despicable Me 2")',
  artists: ['Pharrell Williams'],
  album: 'G I R L',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/76/ff/5e/76ff5ee0-7ab4-2ac2-2598-486a9ccc06e1/886444516877.jpg/316x316bf.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/4c/ba/89/4cba89f1-1a8a-3f33-b3ac-d88bcad8b996/mzaf_17135561476274403451.plus.aac.p.m4a',
  mood: 'happy',
);

final Song testSong2 = Song(
  id: 'e299c15b-d2af-3ac6-8404-47dfece3fbff',
  name: 'All of Me',
  artists: ['John Legend'],
  album: 'Love in the Future (Expanded Edition)',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/22/71/b9/2271b906-85b3-06ee-e611-489b91df0b73/886444160742.jpg/316x316bb.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e2/99/c1/e299c15b-d2af-3ac6-8404-47dfece3fbff/mzaf_7741965493973309922.plus.aac.p.m4a',
  mood: 'romantic',
);

final Song testSong3 = Song(
  id: 'a8180170-4d31-6d06-ab08-19fe14df0b9a',
  name: 'MAMA',
  artists: ['NF'],
  album: 'HOPE',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/5a/6d/1a/5a6d1a4e-ac13-c7e8-1eba-e80a35651622/23UMGIM07672.rgb.jpg/300x300bb.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/a8/18/01/a8180170-4d31-6d06-ab08-19fe14df0b9a/mzaf_12383106996798845603.plus.aac.p.m4a',
  mood: 'happy',
);

final Song testSong4 = Song(
  id: '38756b7b-04a7-0235-07e2-af911972ee4d',
  name: 'Stay (feat. Mikky Ekko)',
  artists: ['Rihanna'],
  album: 'Unapologetic (Deluxe Version)',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/d3/72/50/d3725004-0117-e76d-47f3-00b185e9dd82/12UMGIM59888.rgb.jpg/300x300bb.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/38/75/6b/38756b7b-04a7-0235-07e2-af911972ee4d/mzaf_9832731676841188603.plus.aac.p.m4a',
  mood: 'sad',
);

final Song testSong5 = Song(
  id: 'e6963b9f-25cf-2167-5ef6-1c8180d0f3e1',
  name: 'Sad',
  artists: ['Maroon 5'],
  album: 'Overexposed (Deluxe Version)',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/1b/5b/95/1b5b95d1-b7f2-f2e9-acb2-22f558017056/12UMGIM26178.rgb.jpg/316x316bb.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e6/96/3b/e6963b9f-25cf-2167-5ef6-1c8180d0f3e1/mzaf_16644158447807991767.plus.aac.p.m4a',
  mood: 'sad',
);

final Song testSong6 = Song(
  id: '1686f50d-8b77-7e32-85f7-5f0e804d68fe',
  name: 'Watermelon Sugar',
  artists: ['Harry Styles'],
  album: 'Fine Line',
  image:
      'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/2b/c4/c9/2bc4c9d4-3bc6-ab13-3f71-df0b89b173de/886448022213.jpg/300x300bb.webp',
  audioUrl:
      'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/16/86/f5/1686f50d-8b77-7e32-85f7-5f0e804d68fe/mzaf_14195633304344507287.plus.aac.p.m4a',
  mood: 'happy',
);

List<Song> likedSong = [];
List<Song> historySong = [];
