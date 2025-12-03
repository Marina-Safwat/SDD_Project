import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/data/data.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/features/profile/profile_screen.dart';
import 'package:smp/services/api_service.dart';
import 'package:smp/features/home/song_card.dart';

class MoodHomeScreen extends StatefulWidget {
  const MoodHomeScreen({
    super.key,
    required this.mood,
    required this.onSongSelected,
  });

  final Mood mood;

  /// When a song is tapped, we also pass the full playlist + index so that
  /// TabsScreen can handle Next/Previous.
  final void Function(
    Song song, {
    List<Song>? playlist,
    int? index,
  }) onSongSelected;

  @override
  State<MoodHomeScreen> createState() => _MoodHomeScreenState();
}

class _MoodHomeScreenState extends State<MoodHomeScreen> {
  late Future<ApiResponse<List<Song>>> _playlistFuture;
  late Future<ApiResponse<Song>> _recommendedFuture;
  late String _currentMoodName;

  void _likeSong() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _currentMoodName = widget.mood.name;
    _loadData();
  }

  void _loadData() {
    debugPrint('🎭 Loading playlist for mood: $_currentMoodName');

    // Mood-based playlist
    _playlistFuture = ApiService.fetchPlaylist(
      mood: _currentMoodName,
      limit: 10,
    );

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _recommendedFuture = ApiService.nextSong(user.uid, _currentMoodName);
    } else {
      _recommendedFuture =
          Future.value(ApiResponse.failure('User not logged in'));
    }
  }

  Future<HistorySongResponse> _buildHistoryFuture() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.value(
        HistorySongResponse(success: false, songs: []),
      );
    }
    return ApiService.fetchHistory(userId: user.uid);
  }

  Future<LikedSongsResponse> _buildLikedFuture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❤️ Liked: no user logged in');
      return Future.value(
        LikedSongsResponse(success: false, songs: []),
      );
    }
    debugPrint('❤️ Fetching liked songs for user: ${user.uid}');
    final res = await ApiService.fetchLikedSongs(userId: user.uid);
    debugPrint(
        '❤️ Liked response -> success: ${res.success}, count: ${res.songs.length}');
    return res;
  }

  Future<void> _onMoodSelected(Mood mood) async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _currentMoodName = mood.name;
      _loadData();
    });

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

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 'User';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return _capitalize(user.displayName!);
    }
    if (user.email != null && user.email!.contains('@')) {
      return _capitalize(user.email!.split('@').first);
    }
    return 'User';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final name = _getUserName();

    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }

    return '$greeting, $name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          _getGreeting(),
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    onSongSelected: widget.onSongSelected,
                  ),
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

          // 🔁 SHUFFLE: make a copy and shuffle it locally
          final moodSongs = List<Song>.from(response.data!);
          if (moodSongs.isNotEmpty) {
            moodSongs.shuffle(
                Random()); // optional: Random(seed) if you want stable order
          }

          if (moodSongs.isEmpty) {
            return const Center(child: Text('No songs found.'));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // ================== Recommended song ==================
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
                            ),
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
                    'Songs for your mood: $_currentMoodName',
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
                          // 🔹 Pass song + full (shuffled) mood playlist + index
                          widget.onSongSelected(
                            song,
                            playlist: moodSongs,
                            index: index,
                          );
                        },
                        child: SongCard(
                          song: song,
                          onTap: (s) {
                            widget.onSongSelected(
                              s,
                              playlist: moodSongs,
                              index: index,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ================== Mood selector ==================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Do you want to change it?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: moodss.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final mood = moodss[index];
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

                //   Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Text(
                //     'Songs for your mood: $_currentMoodName',
                //     style: Theme.of(context).textTheme.titleLarge,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // SizedBox(
                //   height: 240,
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: likedSong.length,
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     itemBuilder: (context, index) {
                //       final song = likedSong[index];
                //       return GestureDetector(
                //         onTap: () {
                //           // 🔹 Pass song + full (shuffled) mood playlist + index
                //           widget.onSongSelected(
                //             song,
                //             playlist: moodSongs,
                //             index: index,
                //           );
                //         },
                //         child: SongCard(
                //           song: song,
                //           onTap: (s) {
                //             widget.onSongSelected(
                //               s,
                //               playlist: moodSongs,
                //               index: index,
                //             );
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),

                //Liked + History as you already have them...
                // FutureBuilder<LikedSongsResponse>(
                //   future: _buildLikedFuture(),
                //   builder: (context, likedSnapshot) {
                //     final isLoading = likedSnapshot.connectionState ==
                //         ConnectionState.waiting;
                //     final hasError = likedSnapshot.hasError;
                //     final likedData = likedSnapshot.data;
                //     final likedSongs = likedSong;

                //     debugPrint('❤️ FB state: $isLoading, error: $hasError, '
                //         'dataSuccess: ${likedData?.success}, songs: ${likedSongs.length}');

                //     return Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 16),
                //           child: Text(
                //             'Your liked songs',
                //             style: Theme.of(context).textTheme.titleLarge,
                //           ),
                //         ),
                //         const SizedBox(height: 12),
                //         if (isLoading)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: SizedBox(
                //               height: 40,
                //               child: Center(
                //                 child: CircularProgressIndicator(),
                //               ),
                //             ),
                //           )
                //         else if (hasError)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: Text('Could not load liked songs.'),
                //           )
                //         else if (!(likedData?.success ?? false) ||
                //             likedSongs.isEmpty)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: SizedBox(
                //               height: 140,
                //               child: Center(
                //                 child: Text(
                //                   'You have not liked any songs yet.',
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(fontSize: 16),
                //                 ),
                //               ),
                //             ),
                //           )

                // Liked + History as you already have them...
                FutureBuilder<LikedSongsResponse>(
                  future: _buildLikedFuture(),
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
                        else if (!(likedData?.success ?? false) ||
                            likedSong.isEmpty)
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
                              itemCount: likedSong.length,
                              itemBuilder: (context, index) {
                                final song = likedSong[index];
                                return GestureDetector(
                                  onTap: () => widget.onSongSelected(song),
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

                // FutureBuilder<HistorySongResponse>(
                //   future: _buildHistoryFuture(),
                //   builder: (context, historySnapshot) {
                //     final isLoading = historySnapshot.connectionState ==
                //         ConnectionState.waiting;
                //     final hasError = historySnapshot.hasError;
                //     final historyData = historySnapshot.data;
                //     final localSongs = historyData?.songs ?? [];

                //     return Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 16),
                //           child: Text(
                //             'Your listening history',
                //             style: Theme.of(context).textTheme.titleLarge,
                //           ),
                //         ),
                //         const SizedBox(height: 12),
                //         if (isLoading)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: SizedBox(
                //               height: 40,
                //               child: Center(
                //                 child: CircularProgressIndicator(),
                //               ),
                //             ),
                //           )
                //         else if (hasError)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: Text('Could not load history.'),
                //           )
                //         else if (!(historyData?.success ?? false) ||
                //             localSongs.isEmpty)
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16),
                //             child: SizedBox(
                //               height: 140,
                //               child: Center(
                //                 child: Text(
                //                   'No listening history yet.',
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(fontSize: 16),
                //                 ),
                //               ),
                //             ),
                //           )
                //         else
                //           SizedBox(
                //             height: 240,
                //             child: ListView.builder(
                //               scrollDirection: Axis.horizontal,
                //               padding:
                //                   const EdgeInsets.symmetric(horizontal: 16),
                //               itemCount: localSongs.length,
                //               itemBuilder: (context, index) {
                //                 final song = localSongs[index];
                //                 return GestureDetector(
                //                   onTap: () => widget.onSongSelected(song),
                //                   child: SongCard(
                //                     song: song,
                //                     onTap: widget.onSongSelected,
                //                   ),
                //                 );
                //               },
                //             ),
                //           ),
                //       ],
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
