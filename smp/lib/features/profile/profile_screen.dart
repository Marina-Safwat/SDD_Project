import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/data/data.dart';
import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/models/user_profile.dart';
import 'package:smp/features/profile/history_songs_screen.dart'; // UPDATED import
import 'package:smp/features/profile/liked_songs_screen.dart'; // UPDATED import
import 'package:smp/services/api_service.dart';
import 'package:smp/features/profile/change_password.dart';
import 'package:smp/features/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onSongSelected, // NEW
  });

  /// When a song is tapped, we also optionally pass the full playlist + index
  /// so that TabsScreen can handle Next/Previous.
  final void Function(
    Song song, {
    List<Song>? playlist,
    int? index,
  }) onSongSelected;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;
  final user = FirebaseAuth.instance.currentUser;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No logged-in user');
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _profile.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
      }
      setState(() {
        _profile.name = newName;
      });
    }
  }

  Future<void> _onMoodSelected(Mood mood) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await ApiService.updateUserMood(user.uid, mood.name);
      } catch (e) {
        debugPrint('Failed to update user mood: $e');
      }
    }
  }

  Future<void> _editBio() async {
    final controller = TextEditingController(text: _profile.bio ?? '');

    final newBio = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit bio'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newBio != null) {
      setState(() {
        _profile.bio = newBio;
      });
      // later: save to Firestore
    }
  }

  void _pickFavoriteMood() async {
    final selected = await showModalBottomSheet<Mood>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: moodss.length,
          itemBuilder: (context, index) {
            final mood = moodss[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: mood.color.withOpacity(0.2),
                child: Icon(mood.icon, color: mood.color),
              ),
              title: Text(mood.name),
              onTap: () => Navigator.pop(context, mood),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _profile.favoriteMood = selected;
      });
      // later: save to backend if needed
      await _onMoodSelected(selected);
    }
  }

  void logout() async {
    try {
      await authService.value.googleSignOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _profile = users[user!.email]!; // same as before
    final mood = _profile.favoriteMood;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: (user == null)
          ? const Center(
              child: Text(
                'No User Logged In',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar + name + email
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profile.photoUrl != null
                            ? NetworkImage(_profile.photoUrl!)
                            : null,
                        child: _profile.photoUrl == null
                            ? Text(
                                _profile.name.isNotEmpty
                                    ? _profile.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _profile.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: _editName,
                                ),
                              ],
                            ),
                            Text(
                              _profile.email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bio
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: const Text('Bio'),
                      subtitle: Text(
                        _profile.bio?.isNotEmpty == true
                            ? _profile.bio!
                            : 'Add a short bio about yourself',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _editBio,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Favorite mood
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: const Text('Your mood'),
                      subtitle: Text(
                        mood != null ? mood.name : 'Choose your mood',
                      ),
                      leading: mood != null
                          ? CircleAvatar(
                              backgroundColor: mood.color.withOpacity(0.2),
                              child: Icon(mood.icon, color: mood.color),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.mood),
                            ),
                      onTap: _pickFavoriteMood,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const ChangePassword(),
                  const SizedBox(height: 16),

                  // Playlists section -> Liked + History
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your playlists',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Liked songs
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text('Liked songs'),
                      subtitle: const Text('Songs you liked'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LikedSongsScreen(
                              onSongSelected: widget.onSongSelected, // NEW
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // History
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Listening history'),
                      subtitle: const Text('Songs you listened to recently'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistorySongsScreen(
                              onSongSelected: widget.onSongSelected, // NEW
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Log out'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
