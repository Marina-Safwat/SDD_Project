import 'package:flutter/material.dart';
import 'package:smp/models/music.dart';
import 'package:smp/services/category_operations.dart';
import 'package:smp/models/category.dart';
import 'package:smp/services/music_operations.dart';
import 'package:smp/services/spotify_service.dart';

class Home extends StatefulWidget {
  final Function _miniPlayer;
  Home(this._miniPlayer);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Music> spotifyTracks = [];
  bool isLoading = true;

  final SpotifyService _spotifyService = SpotifyService();

  @override
  void initState() {
    super.initState();
    _loadSpotifyMusic();
  }

  void _loadSpotifyMusic() async {
    List<Music> tracks = await _spotifyService.getTop50Global();
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
    List<Category> categoryList = CategoryOperations.getCategories();
    //convert data to widget using map functions
    List<Widget> categories = categoryList
        .map((Category category) => createCategory(category))
        .toList();
    return categories;
  }

  Widget createMusic(Music music) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 200,
              width: 200,
              child: InkWell(
                  onTap: () {
                    widget._miniPlayer(music, stop: true);
                  },
                  child: Image.network(music.image, fit: BoxFit.cover))),
          Text(
            music.name,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            music.description,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            music.mood,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget createMusicList(String label) {
    List<Music> musicList = MusicOperations.getMusic();
    List<Music> spotifyTracks = [];
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              padding: EdgeInsets.all(5),
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createMusic(spotifyTracks[index]);
              },
              itemCount: spotifyTracks.length,
            ),
          )
        ],
      ),
    );
  }

  Widget createGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 285,
      child: GridView.count(
        childAspectRatio: 5 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: createListOfCategories(),
      ),
    );
  }

  Widget createAppBar(String message) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(message),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.person),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              createAppBar('Good Morning'),
              SizedBox(
                height: 5,
              ),
              createGrid(),
              createMusicList('Recommended For Your '),
              createMusicList('Popular Playlist'),
            ],
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade100,
                    Theme.of(context).primaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.3])),
          // color: Colors.red,
        ),
      ),
    );
  }
}
