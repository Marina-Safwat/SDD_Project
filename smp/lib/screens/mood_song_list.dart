import 'package:flutter/material.dart';
import 'package:smp/models/music.dart';
import 'package:smp/services/spotify_service.dart';

class MoodSongList extends StatefulWidget {
  final String mood;

  MoodSongList({required this.mood});

  @override
  _MoodSongListState createState() => _MoodSongListState();
}

class _MoodSongListState extends State<MoodSongList> {
  final SpotifyService _spotifyService = SpotifyService();
  List<Music> _tracks = [];
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${widget.mood} Songs'),
        backgroundColor: Colors.black87,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _tracks.isEmpty
              ? Center(
                  child: Text(
                    'No songs found for mood "${widget.mood}".',
                    style: TextStyle(color: Colors.white70),
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
                          : Icon(Icons.music_note, color: Colors.white),
                      title: Text(
                        track.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${track.artist}  •  ${track.description}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: track.audioURL.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.play_arrow, color: Colors.white),
                              onPressed: () {
                                print('▶ Preview URL: ${track.audioURL}');
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
