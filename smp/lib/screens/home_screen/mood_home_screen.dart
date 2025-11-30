import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/profile_screen/profile_screen.dart';
import 'package:smp/screens/profile_screen/profile_screen_.dart';
import 'package:smp/services/apiService.dart';
import 'package:smp/widgets/home_screen/category_title.dart';
import 'package:smp/widgets/home_screen/grid.dart';
import 'package:smp/widgets/home_screen/song_card.dart';

class MoodHomeScreen extends StatefulWidget {
  const MoodHomeScreen({
    super.key,
    required this.mood,
    required this.onSongSelected,
    required this.miniPlayer,
  });

  final Mood mood;
  final void Function(Song) onSongSelected;
  final Widget Function(Song?) miniPlayer;

  @override
  State<MoodHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MoodHomeScreen> {
  late Future<ApiResponse<List<Song>>> _playlistFuture;
  late Future<HistorySongResponse> _likedFuture;
  late Future<HistorySongResponse> _historyFuture;
  late Future<ApiResponse<Song>> _recommendedFuture;
  late String _currentMoodName;

  @override
  void initState() {
    super.initState();
    _currentMoodName = widget.mood.name;
    _loadData();
  }

  void _loadData() {
    // Mood-based playlist
    _playlistFuture = ApiService.fetchPlaylist(
      mood: _currentMoodName,
      limit: 10,
    );

    final user = FirebaseAuth.instance.currentUser;

    // For now we use the same history endpoint as data source.
    // Later you can replace _likedFuture with a real "liked songs" API.
    if (user != null) {
      _likedFuture = ApiService.fetchHistory(userId: user.uid);
      _historyFuture = ApiService.fetchHistory(userId: user.uid);
      _recommendedFuture = ApiService.nextSong(user.uid, _currentMoodName);
    } else {
      _likedFuture =
          Future.value(HistorySongResponse(success: false, songs: []));
      _historyFuture =
          Future.value(HistorySongResponse(success: false, songs: []));
      _recommendedFuture =
          Future.value(ApiResponse.failure('User not logged in'));
    }
  }

  Future<void> _onMoodSelected(Mood mood) async {
    final user = FirebaseAuth.instance.currentUser;

    // Update the current mood & reload data
    setState(() {
      _currentMoodName = mood.name;
      _loadData();
    });

    // Inform backend about mood change
    if (user != null) {
      try {
        await ApiService.updateUserMood(user.uid, mood.name);
      } catch (e) {
        debugPrint('Failed to update user mood: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(_loadData);
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    final name = getUserName();

    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }

    return "$greeting, $name";
  }

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "User";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return capitalize(user.displayName!);
    }
    if (user.email != null && user.email!.contains("@")) {
      return capitalize(user.email!.split('@').first);
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          getGreeting(),
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: FutureBuilder<ApiResponse<List<Song>>>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final response = snapshot.data;

          if (response == null || !response.success || response.data == null) {
            return Center(
              child: Text(response?.error ?? 'No songs found for this mood.'),
            );
          }

          final moodSongs = response.data!;
          if (moodSongs.isEmpty) {
            return const Center(child: Text('No songs found.'));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // 🔹 NEW – Recommended song section
                FutureBuilder<ApiResponse<Song>>(
                  future: _recommendedFuture,
                  builder: (context, recSnapshot) {
                    final isLoading =
                        recSnapshot.connectionState == ConnectionState.waiting;
                    final hasError = recSnapshot.hasError;
                    final recData = recSnapshot.data;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Recommended for you',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 40,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        else if (hasError ||
                            recData == null ||
                            !recData.success ||
                            recData.data == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 140,
                              child: Center(
                                child: Text(
                                  'No recommendation available right now.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                widget.onSongSelected(recData.data!);
                              },
                              child: SongCard(
                                song: recData.data!,
                                onTap: widget.onSongSelected,
                              ),
                            ), // ⭐ reuse your card
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
                // ================== Mood playlist ==================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Songs for your mood: ${_currentMoodName}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: moodSongs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final song = moodSongs[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onSongSelected(song);
                        },
                        child: SongCard(
                          song: song,
                          onTap: widget.onSongSelected,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                // 🔹 NEW: Mood selector title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Do you want to change it?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                const SizedBox(height: 12),
                // 🔹 NEW: mood selector bar
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: moodss.length, // from data.dart
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final mood = moodss[index]; // Mood object
                      final isSelected = mood.name == _currentMoodName;

                      return ChoiceChip(
                        label: Text(mood.name),
                        selected: isSelected,
                        onSelected: (_) => _onMoodSelected(mood),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ================== Liked songs (always show title) ==================
                FutureBuilder<HistorySongResponse>(
                  future: _likedFuture,
                  builder: (context, likedSnapshot) {
                    final isLoading = likedSnapshot.connectionState ==
                        ConnectionState.waiting;
                    final hasError = likedSnapshot.hasError;
                    final likedData = likedSnapshot.data;
                    final likedSongs = likedData?.songs ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Your liked songs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        else if (hasError)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Could not load liked songs.'),
                          )
                        else if (likedSongs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 140,
                              child: Center(
                                child: Text(
                                  'You have not liked any songs yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: likedSongs.length,
                              itemBuilder: (context, index) {
                                final song = likedSongs[index];
                                return GestureDetector(
                                  onTap: () {
                                    widget.onSongSelected(song);
                                  },
                                  child: SongCard(
                                    song: song,
                                    onTap: widget.onSongSelected,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ================== History / Recently played (always show title) ==================
                FutureBuilder<HistorySongResponse>(
                  future: _historyFuture,
                  builder: (context, historySnapshot) {
                    final isLoading = historySnapshot.connectionState ==
                        ConnectionState.waiting;
                    final hasError = historySnapshot.hasError;
                    final historyData = historySnapshot.data;
                    final historySongs = historyData?.songs ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Your listening history',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        else if (hasError)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Could not load history.'),
                          )
                        else if (historySongs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 140,
                              child: Center(
                                child: Text(
                                  'No listening history yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: historySongs.length,
                              itemBuilder: (context, index) {
                                final song = historySongs[index];
                                return GestureDetector(
                                  onTap: () {
                                    widget.onSongSelected(song);
                                  },
                                  child: SongCard(
                                    song: song,
                                    onTap: widget.onSongSelected,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
