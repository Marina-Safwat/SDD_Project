import 'package:flutter/material.dart';
import 'package:smp/models/music.dart';
import 'package:smp/services/spotify_service.dart';

class SearchSongList extends StatefulWidget {
  final String Search;

  SearchSongList({required this.Search});

  @override
  _SearchSongListState createState() => _SearchSongListState();
}

class _SearchSongListState extends State<SearchSongList> {
  final SpotifyService _spotifyService = SpotifyService();
  List<Music> _tracks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchSongs();
  }

  Future<void> _loadSearchSongs() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Authenticating...');
      await _spotifyService.authenticate();

      print('🎵 Loading songs for Search: ${widget.Search} ...');
      final tracks =
          await _spotifyService.searchTracks(widget.Search, limit: 20);

      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });

      print('✅ Search "${widget.Search}" loaded ${_tracks.length} tracks');
    } catch (e) {
      print('❌ Error loading Search tracks: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      appBar: AppBar(
        title: Text('${widget.Search} Songs'),
        backgroundColor: Colors.black87,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _tracks.isEmpty
              ? Center(
                  child: Text(
                    'No songs found for Search "${widget.Search}".',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _tracks.length,
                  itemBuilder: (ctx, index) {
                    final track = _tracks[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
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
                                icon:
                                    Icon(Icons.play_arrow, color: Colors.white),
                                onPressed: () {
                                  print('▶ Preview URL: ${track.audioURL}');
                                  // later you connect to your mini-player
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
