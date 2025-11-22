import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/models/user_profile.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/screens/home_screen/category_details_screen.dart';
import 'package:smp/screens/login/login_screen.dart';
import 'package:smp/widgets/profile_screen/change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
      // You can redirect to login here if needed
      throw Exception('No logged-in user');
    }

    //_profile = UserProfile.fromFirebaseUser(user);
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
          itemCount: moods.length,
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
      // later: save to Firestore
    }
  }

  void logout() async {
    try {
      //await authService.value.signOut();
      await authService.value.googleSignOut();
      Navigator.push(
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
    _profile = users[user!.email]!;
    final mood = _profile.favoriteMood;

    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
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

                  // Playlists section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your playlists',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._profile.playlists.map(
                    (p) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.playlist_play),
                        title: Text(p.category.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsScreen(
                                music: p,
                              ),
                            ),
                          );
                        },
                      ),
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
