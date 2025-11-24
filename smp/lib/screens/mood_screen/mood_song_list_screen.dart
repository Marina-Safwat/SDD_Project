import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';
import 'package:smp/services/apiService.dart';

class MoodSongListScreen extends StatefulWidget {
  const MoodSongListScreen({super.key, required this.mood});

  final String mood;

  @override
  State<MoodSongListScreen> createState() => _MoodSongListScreenState();
}

class _MoodSongListScreenState extends State<MoodSongListScreen> {
  final ApiService apiService = ApiService();
  List<Song> songs = []; // ← Empty, will be filled from API
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSongs(); // ← Load from API
  }

  Future<void> _loadSongs() async {
    setState(() => isLoading = true);

    // Get songs from API
    final response = await ApiService.fetchPlaylist(
      mood: widget.mood,
      limit: 20,
    );

    setState(() {
      isLoading = false;
      if (response.success && response.data != null) {
        songs = response.data!; // ← API data here!
      } else {
        error = response.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          title: Text(song.name),
          subtitle: Text(song.artists.join(', ')),
          leading: Image.network(song.image),
        );
      },
    );
  }
}
