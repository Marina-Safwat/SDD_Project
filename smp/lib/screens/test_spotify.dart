// import 'package:flutter/material.dart';
// import 'package:smp/models/music.dart';
// import 'package:smp/services/spotify_service.dart';

// class TestSpotify extends StatefulWidget {
//   @override
//   _TestSpotifyState createState() => _TestSpotifyState();
// }

// class _TestSpotifyState extends State<TestSpotify> {
//   final SpotifyService _spotifyService = SpotifyService();
//   List<Music> _tracks = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadTop50Global();
//   }

//   Future<void> _loadTop50Global() async {
//     setState(() => _isLoading = true);

//     try {
//       print('🔐 Authenticating...');
//       await _spotifyService.authenticate();

//       print('🎵 Loading Top 50 Global...');
//       final tracks = await _spotifyService.getTop50Global(limit: 20);

//       setState(() {
//         _tracks = tracks;
//         _isLoading = false;
//       });

//       print('✅ Total tracks loaded: ${_tracks.length}');
//     } catch (e) {
//       print('❌ Error loading tracks: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Spotify Top 50 Test'),
//         backgroundColor: Colors.green,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _tracks.isEmpty
//               ? Center(child: Text('No tracks found.'))
//               : ListView.builder(
//                   itemCount: _tracks.length,
//                   itemBuilder: (ctx, index) {
//                     final track = _tracks[index];
//                     return ListTile(
//                       leading: track.image.isNotEmpty
//                           ? Image.network(track.image, width: 50, height: 50)
//                           : SizedBox(width: 50, height: 50),
//                       title: Text(track.name),
//                       subtitle: Text(
//                           '${track.artist} | Album: ${track.description} | Mood: ${track.mood}'),
//                       trailing: track.audioURL.isNotEmpty
//                           ? IconButton(
//                               icon: Icon(Icons.play_arrow),
//                               onPressed: () {
//                                 // TODO: play preview from track.audioURL
//                                 print('Preview URL: ${track.audioURL}');
//                               },
//                             )
//                           : null,
//                     );
//                   },
//                 ),
//     );
//   }
// }
