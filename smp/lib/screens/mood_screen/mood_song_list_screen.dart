import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';
import 'package:smp/services/spotify_service.dart';

class MoodSongListScreen extends StatefulWidget {
  const MoodSongListScreen({super.key, required this.mood});

  final String mood;

  @override
  State<MoodSongListScreen> createState() => _MoodSongListScreenState();
}

class _MoodSongListScreenState extends State<MoodSongListScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  List<Song> _tracks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoodSongs();
  }

  Future<void> _loadMoodSongs() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Authenticating...');
      await _spotifyService.authenticate();

      print('🎵 Loading songs for mood: ${widget.mood} ...');
      final tracks =
          await _spotifyService.getTracksByMood(widget.mood, limit: 20);

      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });

      print('✅ Mood "${widget.mood}" loaded ${_tracks.length} tracks');
    } catch (e) {
      print('❌ Error loading mood tracks: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mood} Songs'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _tracks.isEmpty
              ? Center(
                  child: Text(
                    'No songs found for mood "${widget.mood}".',
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _tracks.length,
                  itemBuilder: (ctx, index) {
                    final track = _tracks[index];

                    return ListTile(
                      leading: track.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                track.image,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.music_note,
                              color: Colors.black87,
                            ),
                      title: Text(
                        track.name,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        '${track.artists}',//  •  ${track.description}',
                        style: const TextStyle(
                          color: Colors.black38,
                        ),
                      ),
                      trailing: track.audioUrl != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.black38,
                              ),
                              onPressed: () {
                                print('▶ Preview URL: ${track.audioUrl}');
                                // later you connect to your mini-player
                              },
                            )
                          : null,
                    );
                  },
                ),
    );
  }
}
