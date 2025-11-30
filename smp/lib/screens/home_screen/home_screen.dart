import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/mood.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/profile_screen/profile_screen.dart';
import 'package:smp/screens/profile_screen/profile_screen_.dart';
import 'package:smp/services/apiService.dart';
import 'package:smp/widgets/home_screen/category_title.dart';
import 'package:smp/widgets/home_screen/grid.dart';
import 'package:smp/widgets/home_screen/song_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.mood,
  });

  final Mood mood;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ApiResponse<List<Song>>> _playlistFuture;
  late Future<HistorySongResponse> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _loadHistory();
  }

  Future<void> _loadSongs() async {
    _playlistFuture =
        ApiService.fetchPlaylist(mood: widget.mood.name, limit: 10);
    _playlistFuture.then((response) {
      if (response.success) {
        print('Got ${response.data!.length} songs');
        for (var song in response.data!) {
          print('- ${song.name} by ${song.artists.join(", ")}');
        }
      } else {
        print('Error: ${response.error}');
      }
    });
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _historyFuture = ApiService.fetchHistory(userId: user.uid);
    } else {
      // Not logged in → just return empty list
      _historyFuture =
          Future.value(HistorySongResponse(success: true, songs: []));
    }
    _historyFuture.then((response) {
      if (response.success) {
        print('Got ${response.songs.length} songs');
        for (var song in response.songs) {
          print('- ${song.name} by ${song.artists.join(", ")}');
        }
      } else {
        print('Error: ${response.success}');
      }
    });
  }

  // void _loadSongs() {
  //   _playlistFuture = ApiService.fetchPlaylist(
  //     mood: widget.mood.name,
  //     limit: 20, // change if you want more/less songs
  //   );
  // }

  Future<void> _onRefresh() async {
    setState(() {
      _loadSongs();
      _loadHistory();
    });
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    final name = getUserName();

    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }

    return "$greeting, $name";
  }

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "User";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return capitalize(user.displayName!);
    }
    if (user.email != null && user.email!.contains("@")) {
      return capitalize(user.email!.split('@').first);
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          getGreeting(),
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: FutureBuilder<ApiResponse<List<Song>>>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final response = snapshot.data;

          if (response == null || !response.success || response.data == null) {
            return Center(
              child: Text(response?.error ?? 'No songs found for this mood.'),
            );
          }

          final songs = response.data!;
          if (songs.isEmpty) {
            return const Center(child: Text('No songs found.'));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Songs for your mood: ${widget.mood.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240, // height for horizontal list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: songs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return; //SongCard(song: song);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // body: SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       for (final item in HSSections)
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             CategoryTitle(item.name),
      //             SizedBox(
      //               height: 200,
      //               child: Card(
      //                 child: Grid(
      //                   items: categories,
      //                 ),
      //               ),
      //             )
      //           ],
      //         ),
      //     ],
      //   ),
      // ),
    );
  }
}
