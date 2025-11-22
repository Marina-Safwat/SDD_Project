import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/profile_screen_.dart';
import 'package:smp/models/category.dart';
import 'package:smp/services/spotify_service.dart';
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

  final SpotifyService _spotifyService = SpotifyService();

  @override
  void initState() {
    super.initState();
    _loadSpotifyMusic();
  }

  void _loadSpotifyMusic() async {
    List<Song> tracks = await _spotifyService.getTop50Global();
    setState(() {
      spotifyTracks = tracks;
      isLoading = false;
    });
  }

  Widget createCategory(Category category) {
    return Container(
      color: Color.fromARGB(255, 243, 196, 215),
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
              style: TextStyle(
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
