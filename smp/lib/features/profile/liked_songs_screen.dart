import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/models/song.dart';
import 'package:smp/services/api_service.dart';

/// Screen that shows the user's liked songs.
///
/// Uses the backend /liked endpoint through [ApiService.fetchLikedSongs].
/// When the user taps a song, we call [onSongSelected] with the full
/// liked-songs playlist and the tapped index so the central player flow
/// in TabsScreen can handle playback + Next/Previous.
class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({
    super.key,
    required this.onSongSelected,
  });

  /// Callback to open the player using the shared AudioPlayer in TabsScreen.
  ///
  /// We follow the same signature pattern as MoodHomeScreen:
  ///  - [song]: the tapped song
  ///  - [playlist]: the entire liked-songs list
  ///  - [index]: index of this song in that list
  final void Function(
    Song song, {
    List<Song>? playlist,
    int? index,
  }) onSongSelected;

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  late Future<LikedSongsResponse> _likedFuture;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user -> empty state
      _likedFuture = Future.value(
        LikedSongsResponse(success: false, songs: []),
      );
    } else {
      // Use the dedicated liked-songs endpoint
      _likedFuture = ApiService.fetchLikedSongs(userId: user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked songs'),
        centerTitle: true,
      ),
      body: FutureBuilder<LikedSongsResponse>(
        future: _likedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load liked songs.'),
            );
          }

          final data = snapshot.data;
          final songs = data?.songs ?? [];

          if (!(data?.success ?? false) || songs.isEmpty) {
            return const Center(
              child: Text('You have not liked any songs yet.'),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                leading: song.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song.image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.music_note),
                title: Text(song.name),
                subtitle: Text(
                  song.artists.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // 🔹 Pass full liked playlist + current index,
                  // so TabsScreen can build a queue and make
                  // Next/Previous move inside liked songs.
                  widget.onSongSelected(
                    song,
                    playlist: songs,
                    index: index,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
