import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/profile_screen_.dart';
import 'package:smp/models/category.dart';
import 'package:smp/services/apiService.dart';
// import 'package:smp/services/spotify_service.dart';
import 'package:smp/widgets/home_screen/grid.dart';

class HomeScreen_ extends StatefulWidget {
  const HomeScreen_({super.key});
  //final Function _miniPlayer;
  //HomeScreen(this._miniPlayer);

  @override
  State<HomeScreen_> createState() => _HomeScreen_State();
}

class _HomeScreen_State extends State<HomeScreen_> {
  List<Song> spotifyTracks = [];
  bool isLoading = true;
  String? errorMessage;
  // final SpotifyService _spotifyService = SpotifyService();

  @override
  void initState() {
    super.initState();
    _loadMusic();
  }

  Future<void> _loadMusic() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Option 1: Get popular/party songs for home screen
      final response = await ApiService.fetchPlaylist(
        mood: 'party', // Use 'party' for energetic home screen songs
        limit: 10,
      );

      if (mounted) {
        setState(() {
          isLoading = false;
          if (response.success && response.data != null) {
            spotifyTracks = response.data!;
          } else {
            errorMessage = response.error ?? 'Failed to load songs';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error loading songs: $e';
        });
      }
    }
  }

  Widget createCategory(Category category) {
    return Container(
      color: const Color.fromARGB(255, 243, 196, 215),
      child: Row(
        children: [
          Image.network(
            category.imageURL,
            fit: BoxFit.cover,
          ), // Added missing comma
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              category.name, // Fixed: removed .style
              style: const TextStyle(
                  color: Colors.white), // Fixed: added style parameter
            ),
          )
        ],
      ),
    ); // Added missing semicolon
  }

  List<Widget> createListOfCategories() {
    List<Category> categoryList = HSSections;
    //convert data to widget using map functions
    List<Widget> categories = categoryList
        .map((Category category) => createCategory(category))
        .toList();
    return categories;
  }

  // Widget createMusic(Song song) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 15, left: 0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //             height: 200,
  //             width: 200,
  //             child: InkWell(
  //                 onTap: () {
  //                   widget._miniPlayer(song, stop: true);
  //                 },
  //                 child: Image.network(song.image, fit: BoxFit.cover))),
  //         Text(
  //           song.name,
  //           style: TextStyle(color: Colors.white, fontSize: 16),
  //         ),
  //         Text(
  //           song.description,
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         Text(
  //           song.mood,
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget createMusicList(String label) {
  //   List<Song> spotifyTracks = [];
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 15),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(color: Colors.white, fontSize: 20),
  //         ),
  //         Container(
  //           height: 300,
  //           child: ListView.builder(
  //             padding: EdgeInsets.all(5),
  //             scrollDirection: Axis.horizontal,
  //             itemBuilder: (ctx, index) {
  //               return createMusic(spotifyTracks[index]);
  //             },
  //             itemCount: spotifyTracks.length,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text("Good Morning"),
        actions: [
          IconButton(
            onPressed: () {
              print("I'm in");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen_(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Expanded(
              child: Grid(
                items: categories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
