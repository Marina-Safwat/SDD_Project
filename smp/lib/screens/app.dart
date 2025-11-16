import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smp/models/music.dart';
import 'package:smp/screens/home.dart';
import 'package:smp/screens/playerScreen.dart';
import 'package:smp/screens/search.dart';
import 'package:smp/screens/test_spotify.dart';
import 'package:smp/screens/yourLibrary.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer _audioPlayer = new AudioPlayer();
  var Tabs = [];
  int currentTabIndex = 0;
  bool isPlaying = false;
  Music? music;
  Widget miniPlayer(Music? music, {bool stop = false}) {
    this.music = music;
    setState(() {});
    if (music == null) {
      return SizedBox();
    }
    if (stop) {
      isPlaying = false;
      _audioPlayer.stop();
      return SizedBox();
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
                      await _audioPlayer.play(UrlSource(music.audioURL));
                    } else {
                      await _audioPlayer.pause();
                    }
                    setState(() {});
                  },
                  icon: isPlaying
                      ? Icon(
                          Icons.pause,
                          color: Colors.white,
                        )
                      : Icon(
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
              await _audioPlayer.play(UrlSource(music!.audioURL));
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
    Tabs = [Home(miniPlayer), Search(), Library(), TestSpotify()];
  }

  // UIDesign code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      backgroundColor: Colors.black,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          miniPlayer(music),
          BottomNavigationBar(
            currentIndex: currentTabIndex,
            onTap: (currentIndex) {
              print("current Index is $currentIndex ");
              setState(() {
                currentTabIndex = currentIndex;
              });
            },
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            backgroundColor: Colors.black45,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.white), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.white),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_add, color: Colors.white),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report, color: Colors.white),
                label: 'Test',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
