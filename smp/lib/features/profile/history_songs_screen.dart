import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/models/song.dart';
import 'package:smp/services/api_service.dart';

/// Screen that shows the user's listening history.
///
/// Uses [ApiService.fetchHistory].
/// When the user taps a song, we call [onSongSelected] so the central
/// player/mini-player in TabsScreen handles playback.
class HistorySongsScreen extends StatefulWidget {
  const HistorySongsScreen({
    super.key,
    required this.onSongSelected, // NEW
  });

  /// Callback to open the player using the shared AudioPlayer in TabsScreen.
  final void Function(Song) onSongSelected;

  @override
  State<HistorySongsScreen> createState() => _HistorySongsScreenState();
}

class _HistorySongsScreenState extends State<HistorySongsScreen> {
  late Future<HistorySongResponse> _historyFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _historyFuture =
          Future.value(HistorySongResponse(success: false, songs: []));
    } else {
      _historyFuture = ApiService.fetchHistory(userId: user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening history'),
        centerTitle: true,
      ),
      body: FutureBuilder<HistorySongResponse>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load history.'));
          }

          final data = snapshot.data;
          final songs = data?.songs ?? [];

          if (!(data?.success ?? false) || songs.isEmpty) {
            return const Center(child: Text('No listening history yet.'));
          }

          // reverse to show most recent first (optional)
          final historySongs = songs.reversed.toList();

          return ListView.builder(
            itemCount: historySongs.length,
            itemBuilder: (context, index) {
              final song = historySongs[index];
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
                  // NEW: use shared callback
                  widget.onSongSelected(song);
                },
              );
            },
          );
        },
      ),
    );
  }
}
