import 'dart:math'; // ✅ NEW: for shuffle
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/features/home/mood_home_screen.dart';
import 'package:smp/features/mood/mood_screen.dart';
import 'package:smp/features/player/player_screen.dart';
import 'package:smp/features/profile/profile_screen.dart';
import 'package:smp/features/search/search_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({
    super.key,
    required this.mood,
  });

  final Mood mood;

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  // Shared audio player for the whole app
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Bottom tabs
  late final List<Widget> Tabs;

  int currentTabIndex = 0;

  bool isPlaying = false;
  Song? song; // currently playing song

  // ✅ Queue support for next / previous / shuffle
  List<Song> _currentQueue = [];
  int _currentIndex = -1;

  // =========================================================
  // MAIN ENTRY: when user selects a song anywhere in the app
  // =========================================================
  Future<void> _onSongSelected(
    Song selectedSong, {
    List<Song>? playlist,
    int? index,
  }) async {
    // If we got a playlist + index (e.g. from mood playlist),
    // store them as the active queue.
    if (playlist != null && index != null) {
      _currentQueue = List<Song>.from(playlist);
      _currentIndex = index;
    } else {
      // If no playlist provided (e.g. from search),
      // treat it as a single-song queue.
      _currentQueue = [selectedSong];
      _currentIndex = 0;
    }

    // Make sure `song` matches the current index in queue
    song = _currentQueue[_currentIndex];

    // Start playback
    if (song!.audioUrl != null && song!.audioUrl!.isNotEmpty) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(song!.audioUrl!));
      setState(() {
        isPlaying = true;
      });
    }

    // Open full player screen once we’ve started playback
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          song: song!,
          audioPlayer: _audioPlayer,
          isPlaying: isPlaying,
          onPlayPause: _togglePlayPauseFromPlayer,
        ),
      ),
    );

    // Handle Next / Previous / Shuffle after the player screen is closed
    if (result == 'next') {
      _playNextSong();
    } else if (result == 'previous') {
      _playPreviousSong();
    } else if (result == 'next_shuffle') {
      _playRandomFromQueue();
    }

    setState(() {});
  }

  // =========================================================
  // PLAY / PAUSE
  // =========================================================
  Future<void> _togglePlayPauseFromPlayer() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.resume();
      setState(() => isPlaying = true);
    }
  }

  // =========================================================
  // MINI PLAYER
  // =========================================================
  Widget miniPlayer(Song? song) {
    if (song == null) return const SizedBox();

    return GestureDetector(
      onTap: openPlayerScreen,
      child: Container(
        height: 64,
        color: Colors.blueGrey,
        child: Row(
          children: [
            Image.network(
              song.image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                song.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              onPressed: _togglePlayPauseFromPlayer,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open the full-screen player from the mini-player.
  // Reuses the same queue + currentIndex.
  void openPlayerScreen() {
    if (song == null) return;

    Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          song: song!,
          audioPlayer: _audioPlayer,
          isPlaying: isPlaying,
          onPlayPause: _togglePlayPauseFromPlayer,
        ),
      ),
    ).then((result) {
      if (!mounted) return;

      if (result == 'next') {
        _playNextSong();
      } else if (result == 'previous') {
        _playPreviousSong();
      } else if (result == 'next_shuffle') {
        _playRandomFromQueue();
      }
    });
  }

  // =========================================================
  // QUEUE NAVIGATION: NEXT / PREVIOUS / SHUFFLE
  // =========================================================

  void _playNextSong() {
    if (_currentQueue.isEmpty) return;

    // Move to next index (wrap around)
    _currentIndex = (_currentIndex + 1) % _currentQueue.length;
    final nextSong = _currentQueue[_currentIndex];

    // Reuse the same flow, keeping the same queue
    _onSongSelected(
      nextSong,
      playlist: _currentQueue,
      index: _currentIndex,
    );
  }

  void _playPreviousSong() {
    if (_currentQueue.isEmpty) return;

    // Move to previous index (wrap around)
    _currentIndex =
        (_currentIndex - 1 + _currentQueue.length) % _currentQueue.length;
    final prevSong = _currentQueue[_currentIndex];

    _onSongSelected(
      prevSong,
      playlist: _currentQueue,
      index: _currentIndex,
    );
  }

  /// 🔀 Shuffle: pick a new random song from the current queue.
  /// PlayerScreen will request this by returning 'next_shuffle'.
  void _playRandomFromQueue() {
    if (_currentQueue.isEmpty) return;

    // Only one song -> just replay it
    if (_currentQueue.length == 1) {
      _onSongSelected(
        _currentQueue[0],
        playlist: _currentQueue,
        index: 0,
      );
      return;
    }

    int newIndex = _currentIndex;
    final rand = Random();

    // Avoid picking exactly the same song if possible
    while (newIndex == _currentIndex) {
      newIndex = rand.nextInt(_currentQueue.length);
    }

    final randomSong = _currentQueue[newIndex];

    _onSongSelected(
      randomSong,
      playlist: _currentQueue,
      index: newIndex,
    );
  }

  // =========================================================
  // INIT TABS
  // =========================================================
  @override
  void initState() {
    super.initState();
    Tabs = [
      MoodHomeScreen(
        mood: widget.mood,
        // MoodHomeScreen will pass song + (optionally) playlist + index
        onSongSelected: _onSongSelected,
      ),
      SearchScreen(
        // Search usually passes only the song (single-song queue)
        onTap: _onSongSelected,
      ),
      const MoodScreen(),
      ProfileScreen(
        onSongSelected: _onSongSelected,
      ),
    ];
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          miniPlayer(song),
          BottomNavigationBar(
            currentIndex: currentTabIndex,
            onTap: (currentIndex) {
              setState(() {
                currentTabIndex = currentIndex;
              });
            },
            selectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black26),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.black26),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.branding_watermark, color: Colors.black26),
                label: 'Mood',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.black26),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
