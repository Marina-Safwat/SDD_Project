// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:smp/models/song.dart';
// import 'package:smp/services/apiService.dart';

// class PlayerScreen extends StatefulWidget {
//   final Song song;
//   final AudioPlayer audioPlayer;
//   final bool isPlaying;
//   final VoidCallback onPlayPause;

//   const PlayerScreen({
//     Key? key,
//     required this.song,
//     required this.audioPlayer,
//     required this.isPlaying,
//     required this.onPlayPause,
//   }) : super(key: key);

//   @override
//   State<PlayerScreen> createState() => _PlayerScreenState();
// }

// class _PlayerScreenState extends State<PlayerScreen> {
//   bool isLiked = false;
//   bool isFavorite = false;
//   bool isDisliked = false;
//   Duration currentPosition = Duration.zero;
//   Duration totalDuration = Duration.zero;
//   bool isShuffleOn = false;
//   bool isRepeatOn = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupAudioListeners();
//   }

//   void _setupAudioListeners() {
//     widget.audioPlayer.onPositionChanged.listen((position) {
//       setState(() {
//         currentPosition = position;
//       });
//     });

//     widget.audioPlayer.onDurationChanged.listen((duration) {
//       setState(() {
//         totalDuration = duration;
//       });
//     });

//     // When track finishes, notify backend
//     widget.audioPlayer.onPlayerComplete.listen((_) async {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         try {
//           await ApiService.finishSong(
//             user.uid,
//             widget.song.id,
//             widget.song.mood,
//           );
//         } catch (e) {
//           debugPrint('finishSong failed: $e');
//         }
//       }
//     });
//   }

//   User? get _currentUser => FirebaseAuth.instance.currentUser;

//   Future<void> _toggleLike() async {
//     final user = _currentUser;
//     if (user == null) return;

//     final newValue = !isLiked;

//     setState(() {
//       isLiked = newValue;
//       if (newValue && isDisliked) {
//         isDisliked = false;
//       }
//     });

//     try {
//       // likeSong(userId, songId, mood, bool like)
//       await ApiService.likeSong(
//         user.uid,
//         widget.song.id,
//         widget.song.mood,
//         newValue,
//       );

//       // If we removed dislike, tell backend as well
//       if (!isDisliked) {
//         await ApiService.dislikeSong(
//           user.uid,
//           widget.song.id,
//           widget.song.mood,
//           false,
//         );
//       }
//     } catch (e) {
//       debugPrint('likeSong failed: $e');
//     }
//   }

//   Future<void> _toggleFavorite() async {
//     final user = _currentUser;
//     if (user == null) return;

//     final newValue = !isFavorite;

//     setState(() {
//       isFavorite = newValue;
//     });

//     try {
//       // favoriteSong(userId, songId, mood, bool favorite)
//       await ApiService.favoriteSong(
//         user.uid,
//         widget.song.id,
//         widget.song.mood,
//         newValue,
//       );
//     } catch (e) {
//       debugPrint('favoriteSong failed: $e');
//     }
//   }

//   Future<void> _toggleDislike() async {
//     final user = _currentUser;
//     if (user == null) return;

//     final newValue = !isDisliked;

//     setState(() {
//       isDisliked = newValue;
//       if (newValue && isLiked) {
//         isLiked = false;
//       }
//     });

//     try {
//       // dislikeSong(userId, songId, mood, bool dislike)
//       await ApiService.dislikeSong(
//         user.uid,
//         widget.song.id,
//         widget.song.mood,
//         newValue,
//       );

//       // If we removed like, tell backend
//       if (!isLiked) {
//         await ApiService.likeSong(
//           user.uid,
//           widget.song.id,
//           widget.song.mood,
//           false,
//         );
//       }

//       if (newValue) {
//         // Also tell backend we skipped this song
//         await ApiService.skipSong(
//           user.uid,
//           widget.song.id,
//           widget.song.mood,
//         );
//         // And ask parent to go to next
//         Navigator.pop(context, 'next');
//       }
//     } catch (e) {
//       debugPrint('dislike/skip failed: $e');
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             children: [
//               // Header with back button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.keyboard_arrow_down,
//                       size: 32,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Text(
//                     'Now Playing',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.more_vert, color: Colors.white),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // Album Art
//               Expanded(
//                 child: Center(
//                   child: Hero(
//                     tag: 'song_${widget.song.id}', // use id if available
//                     child: Container(
//                       constraints: const BoxConstraints(
//                         maxWidth: 350,
//                         maxHeight: 350,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.6),
//                             blurRadius: 40,
//                             offset: const Offset(0, 20),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Image.network(
//                           widget.song.image,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Container(
//                             color: Colors.grey[800],
//                             child: const Icon(
//                               Icons.music_note,
//                               size: 120,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Track Info
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Column(
//                   children: [
//                     Text(
//                       widget.song.name,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       widget.song.artists.isNotEmpty
//                           ? widget.song.artists[0]
//                           : 'Unknown Artist',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[400],
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Progress Bar
//               Column(
//                 children: [
//                   SliderTheme(
//                     data: SliderThemeData(
//                       trackHeight: 3,
//                       thumbShape:
//                           const RoundSliderThumbShape(enabledThumbRadius: 6),
//                       overlayShape:
//                           const RoundSliderOverlayShape(overlayRadius: 12),
//                       activeTrackColor: const Color(0xFF1DB954),
//                       inactiveTrackColor: Colors.grey[800],
//                       thumbColor: Colors.white,
//                       overlayColor: const Color(0xFF1DB954).withOpacity(0.2),
//                     ),
//                     child: Slider(
//                       value: currentPosition.inSeconds.toDouble(),
//                       max: totalDuration.inSeconds.toDouble() > 0
//                           ? totalDuration.inSeconds.toDouble()
//                           : 100.0,
//                       onChanged: (value) async {
//                         await widget.audioPlayer
//                             .seek(Duration(seconds: value.toInt()));
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _formatDuration(currentPosition),
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 12,
//                           ),
//                         ),
//                         Text(
//                           _formatDuration(totalDuration),
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Like, Dislike, Favorite Controls
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Dislike Button
//                   IconButton(
//                     onPressed: _toggleDislike,
//                     icon: Icon(
//                       isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
//                       size: 28,
//                     ),
//                     color: isDisliked ? Colors.red : Colors.grey[600],
//                   ),

//                   // Like Button (heart)
//                   IconButton(
//                     onPressed: _toggleLike,
//                     icon: Icon(
//                       isLiked ? Icons.favorite : Icons.favorite_border,
//                       size: 32,
//                     ),
//                     color: isLiked ? Colors.red : Colors.grey[600],
//                   ),

//                   // Favorite Button (star)
//                   IconButton(
//                     onPressed: _toggleFavorite,
//                     icon: Icon(
//                       isFavorite ? Icons.star : Icons.star_border,
//                       size: 32,
//                     ),
//                     color: isFavorite ? Colors.amber : Colors.grey[600],
//                   ),

//                   // Thumbs Up (same state as like)
//                   IconButton(
//                     onPressed: _toggleLike,
//                     icon: Icon(
//                       isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
//                       size: 28,
//                     ),
//                     color: isLiked ? const Color(0xFF1DB954) : Colors.grey[600],
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Playback Controls
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Shuffle
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         isShuffleOn = !isShuffleOn;
//                       });
//                     },
//                     icon: const Icon(Icons.shuffle),
//                     color: isShuffleOn
//                         ? const Color(0xFF1DB954)
//                         : Colors.grey[600],
//                     iconSize: 24,
//                   ),

//                   // Previous
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context, 'previous');
//                     },
//                     icon: const Icon(Icons.skip_previous),
//                     color: Colors.white,
//                     iconSize: 36,
//                   ),

//                   // Play/Pause
//                   Container(
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                     ),
//                     child: IconButton(
//                       onPressed: widget.onPlayPause,
//                       icon: Icon(
//                         widget.isPlaying ? Icons.pause : Icons.play_arrow,
//                         size: 40,
//                       ),
//                       color: Colors.black,
//                     ),
//                   ),

//                   // Next
//                   IconButton(
//                     onPressed: () async {
//                       final user = _currentUser;
//                       if (user != null) {
//                         try {
//                           await ApiService.skipSong(
//                             user.uid,
//                             widget.song.id,
//                             widget.song.mood,
//                           );
//                         } catch (e) {
//                           debugPrint('skipSong failed: $e');
//                         }
//                       }
//                       Navigator.pop(context, 'next');
//                     },
//                     icon: const Icon(Icons.skip_next),
//                     color: Colors.white,
//                     iconSize: 36,
//                   ),

//                   // Repeat (local UI only for now)
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         isRepeatOn = !isRepeatOn;
//                       });
//                     },
//                     icon: const Icon(Icons.repeat),
//                     color:
//                         isRepeatOn ? const Color(0xFF1DB954) : Colors.grey[600],
//                     iconSize: 24,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
