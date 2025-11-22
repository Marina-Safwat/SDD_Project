import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smp/models/song.dart';

class PlayerScreen extends StatefulWidget {
  final Song music;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const PlayerScreen({
    Key? key,
    required this.music,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isLiked = false;
  bool isFavorite = false;
  bool isDisliked = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isShuffleOn = false;
  bool isRepeatOn = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    widget.audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    widget.audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final likedSongs = prefs.getStringList('liked_songs') ?? [];
      final favoriteSongs = prefs.getStringList('favorite_songs') ?? [];
      final dislikedSongs = prefs.getStringList('disliked_songs') ?? [];

      isLiked = likedSongs.contains(widget.music.name);
      isFavorite = favoriteSongs.contains(widget.music.name);
      isDisliked = dislikedSongs.contains(widget.music.name);
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final likedSongs = prefs.getStringList('liked_songs') ?? [];

    setState(() {
      if (isLiked) {
        likedSongs.remove(widget.music.name);
        isLiked = false;
      } else {
        likedSongs.add(widget.music.name);
        isLiked = true;
        // Remove from disliked if it was disliked
        if (isDisliked) {
          _toggleDislike();
        }
      }
    });

    await prefs.setStringList('liked_songs', likedSongs);
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSongs = prefs.getStringList('favorite_songs') ?? [];

    setState(() {
      if (isFavorite) {
        favoriteSongs.remove(widget.music.name);
        isFavorite = false;
      } else {
        favoriteSongs.add(widget.music.name);
        isFavorite = true;
      }
    });

    await prefs.setStringList('favorite_songs', favoriteSongs);
  }

  Future<void> _toggleDislike() async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedSongs = prefs.getStringList('disliked_songs') ?? [];

    setState(() {
      if (isDisliked) {
        dislikedSongs.remove(widget.music.name);
        isDisliked = false;
      } else {
        dislikedSongs.add(widget.music.name);
        isDisliked = true;
        // Remove from liked if it was liked
        if (isLiked) {
          _toggleLike();
        }
        // Auto skip to next song
        Navigator.pop(context, 'next');
      }
    });

    await prefs.setStringList('disliked_songs', dislikedSongs);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Header with back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.keyboard_arrow_down,
                        size: 32, color: Colors.white),
                  ),
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Album Art
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'music_${widget.music.name}',
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 350, maxHeight: 350),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 40,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.music.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: Icon(Icons.music_note,
                                size: 120, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Track Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      widget.music.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.music.artist ?? 'Unknown Artist',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Progress Bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Color(0xFF1DB954),
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.white,
                      overlayColor: Color(0xFF1DB954).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: currentPosition.inSeconds.toDouble(),
                      max: totalDuration.inSeconds.toDouble() > 0
                          ? totalDuration.inSeconds.toDouble()
                          : 100,
                      onChanged: (value) async {
                        await widget.audioPlayer
                            .seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Like, Dislike, Favorite Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Dislike Button
                  IconButton(
                    onPressed: _toggleDislike,
                    icon: Icon(
                      isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                      size: 28,
                    ),
                    color: isDisliked ? Colors.red : Colors.grey[600],
                  ),

                  // Like Button
                  IconButton(
                    onPressed: _toggleLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 32,
                    ),
                    color: isLiked ? Colors.red : Colors.grey[600],
                  ),

                  // Favorite Button
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      size: 32,
                    ),
                    color: isFavorite ? Colors.amber : Colors.grey[600],
                  ),

                  // Thumbs Up
                  IconButton(
                    onPressed: _toggleLike,
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 28,
                    ),
                    color: isLiked ? Color(0xFF1DB954) : Colors.grey[600],
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isShuffleOn = !isShuffleOn;
                      });
                    },
                    icon: Icon(Icons.shuffle),
                    color: isShuffleOn ? Color(0xFF1DB954) : Colors.grey[600],
                    iconSize: 24,
                  ),

                  // Previous
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, 'previous');
                    },
                    icon: Icon(Icons.skip_previous),
                    color: Colors.white,
                    iconSize: 36,
                  ),

                  // Play/Pause
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: widget.onPlayPause,
                      icon: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                      ),
                      color: Colors.black,
                    ),
                  ),

                  // Next
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, 'next');
                    },
                    icon: Icon(Icons.skip_next),
                    color: Colors.white,
                    iconSize: 36,
                  ),

                  // Repeat
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isRepeatOn = !isRepeatOn;
                      });
                    },
                    icon: Icon(Icons.repeat),
                    color: isRepeatOn ? Color(0xFF1DB954) : Colors.grey[600],
                    iconSize: 24,
                  ),
                ],
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
