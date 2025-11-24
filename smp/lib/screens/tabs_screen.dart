import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/home_screen/home_screen.dart';
import 'package:smp/screens/profile_screen.dart';
import 'package:smp/screens/mood_screen/mood_screen.dart';
import 'package:smp/screens/playerScreen.dart';
import 'package:smp/screens/search_screen/search_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  var Tabs = [];
  int currentTabIndex = 2;
  bool isPlaying = false;
  Song? music;

  String? get selectedMood => null;
  Widget miniPlayer(Song? music, {bool stop = false}) {
    this.music = music;
    setState(() {});
    if (music == null) {
      return const SizedBox();
    }
    if (stop) {
      isPlaying = false;
      _audioPlayer.stop();
      return const SizedBox();
    }
    setState(() {});
    Size deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: openPlayerScreen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Colors.blueGrey,
        width: deviceSize.width,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(music.image, fit: BoxFit.cover),
              Text(
                music.name,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              IconButton(
                  onPressed: () async {
                    isPlaying = !isPlaying;
                    if (isPlaying) {
                      await _audioPlayer.play(UrlSource(music.audioUrl ?? ''));
                    } else {
                      await _audioPlayer.pause();
                    }
                    setState(() {});
                  },
                  icon: isPlaying
                      ? const Icon(
                          Icons.pause,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ))
            ],
          ),
        ),
      ),
    );
  }

  void openPlayerScreen() {
    if (music == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          music: music!,
          audioPlayer: _audioPlayer,
          isPlaying: isPlaying,
          onPlayPause: () async {
            isPlaying = !isPlaying;
            if (isPlaying) {
              await _audioPlayer.play(UrlSource(music!.audioUrl ?? ''));
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

  void _handleMoodSelected(String mood) {
    setState(() {
      var selectedMood = mood;
      Tabs[0] = HomeScreen(mood: selectedMood);
      currentTabIndex = 0; // Switch to Home tab when a mood is selected
    });
  }

  @override
  void initState() {
    super.initState();
    Tabs = [
      HomeScreen(mood: selectedMood), //miniPlayer),
      const SearchScreen(),
      MoodScreen(onMoodSelected: _handleMoodSelected),
      const ProfileScreen(),
    ];
  }

  // UIDesign code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      //backgroundColor: Colors.black,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //miniPlayer(music),
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
