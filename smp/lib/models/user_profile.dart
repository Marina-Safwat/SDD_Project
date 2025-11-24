import 'package:firebase_auth/firebase_auth.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/music.dart'; // your Mood model

class UserProfile {
  final String uid;
  String name;
  String email;
  String? photoUrl;
  String? bio;
  Mood favoriteMood;
  List<Music> playlists;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.favoriteMood,
    this.playlists = const [],
  });

  factory UserProfile.fromFirebaseUser(User user) {
    final email = user.email ?? '';
    final displayName =
        (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : email.split('@').first;

    return UserProfile(
      uid: user.uid,
      name: _capitalize(displayName),
      email: email,
      photoUrl: user.photoURL,
      // defaults for now; later you can load from Firestore
      bio: 'Music lover 🎵',
      favoriteMood: moods["Happy"]!,
      playlists: categories,
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}
