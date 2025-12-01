import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/models/mood.dart';
import 'package:smp/models/music.dart';

class UserProfile {
  /// Firebase UID for this user.
  final String uid;

  /// Display name (editable from profile screen).
  String name;

  /// Email address (we treat as stable identifier).
  final String email;

  /// Optional profile photo URL.
  String? photoUrl;

  /// Optional short bio.
  String? bio;

  /// User's current or favorite mood.
  Mood favoriteMood;

  /// Optional playlists associated with this user.
  /// Currently used only for demo / seed data in [data.dart].
  List<Music> playlists;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.favoriteMood,
    List<Music>? playlists,
  }) : playlists = playlists ?? [];

  /// Build a profile from a Firebase [User].
  ///
  /// - Name: uses displayName if present, otherwise the part of email before '@'.
  /// - Bio: a simple default for now.
  /// - Favorite mood: default to "Happy".
  /// - Playlists: starts empty (you can fill later from backend).
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
      bio: 'Music lover 🎵',
      favoriteMood: const Mood('Happy', Icons.emoji_emotions, Colors.orange),
      playlists: const [],
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}
