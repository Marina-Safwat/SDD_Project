import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/home_screen/home_screen.dart';
import 'package:smp/screens/home_screen/mood_home_screen.dart';
import 'package:smp/screens/profile_screen/profile_screen.dart';
import 'package:smp/screens/mood_screen/mood_screen.dart';
import 'package:smp/screens/player_screen/playerScreen.dart';
import 'package:smp/screens/search_screen/search_screen.dart';
import 'package:smp/screens/search_screen/search_screen_.dart';

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
  //chat code start
  // AudioPlayer _audioPlayer = new AudioPlayer();
  // var Tabs = [];
  // int currentTabIndex = 0;
  // bool _isPlaying = false;
  // Song? _currentSong;
  // bool _showMiniPlayer = false;
  // Future<void> _openPlayer(Song song) async {
  //   // If this is a different song, start playing it
  //   if (_currentSong?.id != song.id) {
  //     _currentSong = song;

  //     if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
  //       await _audioPlayer.stop();
  //       await _audioPlayer.play(UrlSource(song.audioUrl!));
  //       setState(() {
  //         _isPlaying = true;
  //         _showMiniPlayer = true;
  //       });
  //     }
  //   } else {
  //     // same song: just ensure we show mini-player
  //     setState(() {
  //       _showMiniPlayer = true;
  //     });
  //   }

  //   final result = await Navigator.push<String>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => PlayerScreen(
  //         song: song,
  //         audioPlayer: _audioPlayer,
  //         isPlaying: _isPlaying,
  //         onPlayPause: _togglePlayPauseFromPlayer,
  //       ),
  //     ),
  //   );

  //   if (result == 'next') {
  //     _playNextSong();
  //   } else if (result == 'previous') {
  //     _playPreviousSong();
  //   }
  // }

  // Future<void> _togglePlayPauseFromPlayer() async {
  //   if (_isPlaying) {
  //     await _audioPlayer.pause();
  //     setState(() => _isPlaying = false);
  //   } else {
  //     await _audioPlayer.resume();
  //     setState(() => _isPlaying = true);
  //   }
  // }

  void _playNextSong() {
    // TODO: implement your queue logic later
    // for now you can leave this empty or use your mood playlist
  }

  void _playPreviousSong() {
    // TODO: implement previous logic if you like
  }

  // void _onSongSelected(Song song) {
  //   _openPlayer(song);
  // }

  // Widget _buildMiniPlayer() {
  //   final song = _currentSong!;
  //   return InkWell(
  //     onTap: () {
  //       _openPlayer(song);
  //     },
  //     child: Container(
  //       height: 64,
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       decoration: const BoxDecoration(
  //         color: Color(0xFF1E1E1E),
  //         border: Border(
  //           top: BorderSide(color: Colors.black54, width: 0.5),
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           // artwork
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(8),
  //             child: Image.network(
  //               song.image,
  //               width: 48,
  //               height: 48,
  //               fit: BoxFit.cover,
  //               errorBuilder: (_, __, ___) => Container(
  //                 width: 48,
  //                 height: 48,
  //                 color: Colors.grey[800],
  //                 child: const Icon(Icons.music_note, color: Colors.white),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           // title + artist
  //           Expanded(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   song.name,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   song.artists.isNotEmpty
  //                       ? song.artists.join(', ')
  //                       : 'Unknown Artist',
  //                   style: TextStyle(
  //                     color: Colors.grey[400],
  //                     fontSize: 12,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           IconButton(
  //             onPressed: _togglePlayPauseFromPlayer,
  //             icon: Icon(
  //               _isPlaying ? Icons.pause : Icons.play_arrow,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //  @override
  // initState() {
  //   super.initState();
  //   Tabs = [
  //     MoodHomeScreen(
  //       mood: widget.mood,
  //       onSongSelected: _onSongSelected,
  //     ), //miniPlayer),
  //     const SearchScreen_(),
  //     const MoodScreen(),
  //     const ProfileScreen(),
  //   ];
  // }
  // //chat code done
  //rachana's code start
  AudioPlayer _audioPlayer = new AudioPlayer();
  var Tabs = [];
  int currentTabIndex = 0;
  bool isPlaying = false;
  Song? song;
  // Widget miniPlayer(Song? song, {bool stop = false}) {
  //   this.song = song;
  //   setState(() {});
  //   if (song == null) {
  //     return SizedBox();
  //   }
  //   if (stop) {
  //     isPlaying = false;
  //     _audioPlayer.stop();
  //     return SizedBox();
  //   }
  //   setState(() {});
  //   Size deviceSize = MediaQuery.of(context).size;
  //   return GestureDetector(
  //     onTap: openPlayerScreen,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 500),
  //       color: Colors.blueGrey,
  //       width: deviceSize.width,
  //       height: 50,
  //       child: Padding(
  //         padding: const EdgeInsets.all(0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Image.network(song.image, fit: BoxFit.cover),
  //             Text(
  //               song.name,
  //               style: const TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //             IconButton(
  //                 onPressed: () async {
  //                   isPlaying = !isPlaying;
  //                   if (isPlaying) {
  //                     await _audioPlayer.play(UrlSource(
  //                         "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"));
  //                   } else {
  //                     await _audioPlayer.pause();
  //                   }
  //                   setState(() {});
  //                 },
  //                 icon: isPlaying
  //                     ? Icon(
  //                         Icons.pause,
  //                         color: Colors.white,
  //                       )
  //                     : Icon(
  //                         Icons.play_arrow,
  //                         color: Colors.white,
  //                       ))
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _onSongSelected(Song song) async {
    this.song = song;

    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(song.audioUrl!)); // 🔹 use actual URL
      setState(() {
        isPlaying = true;
      });
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          song: song,
          audioPlayer: _audioPlayer,
          isPlaying: isPlaying,
          onPlayPause: _togglePlayPauseFromPlayer,
        ),
      ),
    );

    if (result == 'next') {
      _playNextSong();
    } else if (result == 'previous') {
      _playPreviousSong();
    }
  }

  Future<void> _togglePlayPauseFromPlayer() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.resume();
      setState(() => isPlaying = true);
    }
  }

  Widget miniPlayer(Song? song) {
    if (song == null) return const SizedBox(); // 🔹 only show when active
    return GestureDetector(
      onTap: openPlayerScreen,
      child: Container(
        height: 64,
        color: Colors.blueGrey,
        child: Row(
          children: [
            Image.network(song.image, width: 48, height: 48, fit: BoxFit.cover),
            const SizedBox(width: 12),
            Expanded(
              child: Text(song.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
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

  void openPlayerScreen() {
    if (song == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          song: song!,
          audioPlayer: _audioPlayer,
          isPlaying: isPlaying,
          onPlayPause: () async {
            isPlaying = !isPlaying;
            if (isPlaying) {
              await _audioPlayer.play(UrlSource(
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"));
            } else {
              await _audioPlayer.pause();
            }
            setState(() {});
          },
        ),
      ),
    ).then((result) {
      // Handle skip next/previous
      if (result == 'next') {
        print('Skip to next song');
        // Add your next song logic here
      } else if (result == 'previous') {
        print('Skip to previous song');
        // Add your previous song logic here
      }
    });
  }

  @override
  initState() {
    super.initState();
    Tabs = [
      MoodHomeScreen(
        miniPlayer: miniPlayer,
        mood: widget.mood,
        onSongSelected: _onSongSelected,
      ),
      SearchScreen_(
        onTap: _onSongSelected,
      ),
      MoodScreen(),
      ProfileScreen()
    ];
  }
  //rachana's code done

  // UIDesign code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      //backgroundColor: Colors.black,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          miniPlayer(song),
          //if (_showMiniPlayer && _currentSong != null) _buildMiniPlayer(),
          BottomNavigationBar(
            currentIndex: currentTabIndex,
            onTap: (currentIndex) {
              print("current Index is $currentIndex ");
              setState(() {
                currentTabIndex = currentIndex;
              });
            },
            selectedItemColor: Colors.black,
            //unselectedItemColor: Colors.black,
            //backgroundColor: Colors.black45,
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
