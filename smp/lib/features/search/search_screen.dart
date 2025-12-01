import 'package:flutter/material.dart';

import 'package:smp/models/song.dart';
import 'package:smp/services/api_service.dart';

/// Search screen that lets the user search for songs.
///
/// Results are reported via [onTap], which is used in [TabsScreen]
/// to open the full player and update the mini-player.
class SearchScreen extends StatefulWidget {
  /// Optional: pass current mood so backend can personalize results.
  final String? mood;

  /// Callback when a song is selected from the results.
  final void Function(Song) onTap;

  const SearchScreen({
    super.key,
    this.mood,
    required this.onTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Song> _results = [];
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updateSearch(String value) async {
    setState(() {
      _query = value;
      _errorMessage = null;
    });

    final trimmed = value.trim();

    // If the field is cleared → clear results & stop.
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.searchSongs(
        query: trimmed,
        mood: widget.mood ?? 'all', // Adjust if API requires a specific mood.
        limit: 20,
      );

      setState(() {
        _isLoading = false;
        if (response.success) {
          _results = response.songs;
          if (_results.isEmpty) {
            _errorMessage = 'No results found.';
          }
        } else {
          _results = [];
          _errorMessage = 'No results found.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _results = [];
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_query.isEmpty && _results.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search songs',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];

        return ListTile(
          leading: (song.image.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    song.image,
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
            song.name,
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            song.artists.join(', '),
            style: const TextStyle(
              color: Colors.black38,
            ),
          ),
          trailing: song.audioUrl != null
              ? IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.black38,
                  ),
                  onPressed: () {
                    // Optional: hook preview into mini-player later if needed.
                    debugPrint('▶ Preview URL: ${song.audioUrl}');
                  },
                )
              : null,
          onTap: () {
            // Delegate to TabsScreen so it can open the full player & mini-player.
            widget.onTap(song);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
