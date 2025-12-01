import 'dart:async'; // ⭐ NEW

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smp/models/song.dart';
import 'package:smp/services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const PlayerScreen({
    Key? key,
    required this.song,
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

  // ⭐ NEW: fake timer instead of real audio duration
  static const Duration _fakeSongDuration = Duration(minutes: 1);
  Timer? _fakeTimer;

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    // We don't rely on real audio duration; we simulate 1 minute
    totalDuration = _fakeSongDuration;
    _startFakeTimer();
  }

  @override
  void dispose() {
    _cancelFakeTimer();
    super.dispose();
  }

  // ===================== FAKE TIMER LOGIC =====================

  void _startFakeTimer() {
    _cancelFakeTimer(); // make sure we don't have a previous one

    _fakeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final nextPos = currentPosition + const Duration(seconds: 1);

        if (nextPos >= totalDuration) {
          currentPosition = totalDuration;
          timer.cancel();
          _onFakeSongFinished();
        } else {
          currentPosition = nextPos;
        }
      });
    });
  }

  void _cancelFakeTimer() {
    _fakeTimer?.cancel();
    _fakeTimer = null;
  }

  Future<void> _onFakeSongFinished() async {
    final user = FirebaseAuth.instance.currentUser;

    // If repeat is ON, just restart the timer and "song"
    if (isRepeatOn) {
      setState(() {
        currentPosition = Duration.zero;
      });
      _startFakeTimer();
      return;
    }

    // Otherwise, report finished to backend and go to next
    if (user != null) {
      try {
        await ApiService.finishSong(
          user.uid,
          widget.song.id,
          _currentMood(),
        );
      } catch (e) {
        debugPrint('Failed to send finishSong: $e');
      }
    }

    if (!mounted) return;

    final result = isShuffleOn ? 'next_shuffle' : 'next';
    Navigator.pop(context, result);
  }

  // ===================== PREFS & HELPERS =====================

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final likedSongs = prefs.getStringList('liked_songs') ?? [];
      final favoriteSongs = prefs.getStringList('favorite_songs') ?? [];
      final dislikedSongs = prefs.getStringList('disliked_songs') ?? [];

      isLiked = likedSongs.contains(widget.song.id);
      isFavorite = favoriteSongs.contains(widget.song.id);
      isDisliked = dislikedSongs.contains(widget.song.id);
    });
  }

  String? _currentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  String _currentMood() {
    final m = widget.song.mood.trim();
    if (m.isEmpty) return 'happy';
    return m.toLowerCase();
  }

  // ===================== LIKE / FAVORITE / DISLIKE =====================

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final likedSongs = prefs.getStringList('liked_songs') ?? [];
    final dislikedSongs = prefs.getStringList('disliked_songs') ?? [];

    final wasLiked = isLiked;
    final wasDisliked = isDisliked;

    bool newLiked = !wasLiked;
    bool newDisliked = wasDisliked;

    if (newLiked && newDisliked) {
      newDisliked = false;
    }

    setState(() {
      isLiked = newLiked;
      isDisliked = newDisliked;
    });

    if (newLiked) {
      if (!likedSongs.contains(widget.song.id)) {
        likedSongs.add(widget.song.id);
      }
    } else {
      likedSongs.remove(widget.song.id);
    }

    if (newDisliked) {
      if (!dislikedSongs.contains(widget.song.id)) {
        dislikedSongs.add(widget.song.id);
      }
    } else {
      dislikedSongs.remove(widget.song.id);
    }

    await prefs.setStringList('liked_songs', likedSongs);
    await prefs.setStringList('disliked_songs', dislikedSongs);

    final userId = _currentUserId();
    if (userId != null) {
      final mood = _currentMood();
      try {
        await ApiService.likeSong(userId, widget.song.id, mood, newLiked);
        if (wasDisliked != newDisliked) {
          await ApiService.dislikeSong(
            userId,
            widget.song.id,
            mood,
            newDisliked,
          );
        }
      } catch (e) {
        debugPrint('Failed to send like/dislike to backend: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSongs = prefs.getStringList('favorite_songs') ?? [];

    final wasFavorite = isFavorite;
    final newFavorite = !wasFavorite;

    setState(() {
      isFavorite = newFavorite;
    });

    if (newFavorite) {
      if (!favoriteSongs.contains(widget.song.id)) {
        favoriteSongs.add(widget.song.id);
      }
    } else {
      favoriteSongs.remove(widget.song.id);
    }

    await prefs.setStringList('favorite_songs', favoriteSongs);

    final userId = _currentUserId();
    if (userId != null) {
      final mood = _currentMood();
      try {
        await ApiService.favoriteSong(
          userId,
          widget.song.id,
          mood,
          newFavorite,
        );
      } catch (e) {
        debugPrint('Failed to send favorite to backend: $e');
      }
    }
  }

  Future<void> _toggleDislike() async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedSongs = prefs.getStringList('disliked_songs') ?? [];
    final likedSongs = prefs.getStringList('liked_songs') ?? [];

    final wasDisliked = isDisliked;
    final wasLiked = isLiked;

    bool newDisliked = !wasDisliked;
    bool newLiked = wasLiked;

    if (newDisliked && newLiked) {
      newLiked = false;
    }

    setState(() {
      isDisliked = newDisliked;
      isLiked = newLiked;
    });

    if (newDisliked) {
      if (!dislikedSongs.contains(widget.song.id)) {
        dislikedSongs.add(widget.song.id);
      }
    } else {
      dislikedSongs.remove(widget.song.id);
    }

    if (newLiked) {
      if (!likedSongs.contains(widget.song.id)) {
        likedSongs.add(widget.song.id);
      }
    } else {
      likedSongs.remove(widget.song.id);
    }

    await prefs.setStringList('disliked_songs', dislikedSongs);
    await prefs.setStringList('liked_songs', likedSongs);

    final userId = _currentUserId();
    if (userId != null) {
      final mood = _currentMood();
      try {
        await ApiService.dislikeSong(
          userId,
          widget.song.id,
          mood,
          newDisliked,
        );
        if (wasLiked != newLiked) {
          await ApiService.likeSong(
            userId,
            widget.song.id,
            mood,
            newLiked,
          );
        }
      } catch (e) {
        debugPrint('Failed to send dislike/like to backend: $e');
      }
    }

    // If user actively dislikes, we skip to next song
    if (newDisliked && mounted) {
      _cancelFakeTimer();
      final result = isShuffleOn ? 'next_shuffle' : 'next';
      Navigator.pop(context, result);
    }
  }

  // ===================== UI HELPERS =====================

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      _cancelFakeTimer();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 32,
                    ),
                  ),
                  const Text(
                    'Now Playing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Album art
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'song_${widget.song.id}',
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 350,
                        maxHeight: 350,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.song.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              size: 120,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Track info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      widget.song.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.song.artists.isNotEmpty
                          ? widget.song.artists[0]
                          : 'Unknown Artist',
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

              const SizedBox(height: 32),

              // Progress bar (driven by fake timer)
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: const Color(0xFF1DB954),
                      inactiveTrackColor: Colors.grey[800],
                      overlayColor: const Color(0xFF1DB954).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: currentPosition.inSeconds.toDouble(),
                      max: totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        // Allow manual seeking in fake timeline
                        setState(() {
                          currentPosition = Duration(
                              seconds: value
                                  .clamp(0, totalDuration.inSeconds.toDouble())
                                  .toInt());
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Like / Dislike / Favorite row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _toggleDislike,
                    icon: Icon(
                      isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                      size: 28,
                    ),
                    color: isDisliked ? Colors.red : Colors.grey[600],
                  ),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      size: 32,
                    ),
                    color: isFavorite ? Colors.amber : Colors.grey[600],
                  ),
                  IconButton(
                    onPressed: _toggleLike,
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 28,
                    ),
                    color: isLiked ? const Color(0xFF1DB954) : Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Playback controls
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
                    icon: const Icon(Icons.shuffle),
                    color: isShuffleOn
                        ? const Color(0xFF1DB954)
                        : Colors.grey[600],
                    iconSize: 24,
                  ),

                  // Previous
                  IconButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          await ApiService.skipSong(
                            user.uid,
                            widget.song.id,
                            _currentMood(),
                          );
                        } catch (e) {
                          debugPrint('Failed to send skipSong (previous): $e');
                        }
                      }
                      if (mounted) {
                        _cancelFakeTimer();
                        Navigator.pop(context, 'previous');
                      }
                    },
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 36,
                  ),

                  // Play / pause (still calling shared handler in TabsScreen)
                  Container(
                    decoration: const BoxDecoration(
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
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          await ApiService.skipSong(
                            user.uid,
                            widget.song.id,
                            _currentMood(),
                          );
                        } catch (e) {
                          debugPrint('Failed to send skipSong (next): $e');
                        }
                      }
                      if (mounted) {
                        _cancelFakeTimer();
                        final result = isShuffleOn ? 'next_shuffle' : 'next';
                        Navigator.pop(context, result);
                      }
                    },
                    icon: const Icon(Icons.skip_next),
                    iconSize: 36,
                  ),

                  // Repeat
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isRepeatOn = !isRepeatOn;
                      });
                    },
                    icon: const Icon(Icons.repeat),
                    color:
                        isRepeatOn ? const Color(0xFF1DB954) : Colors.grey[600],
                    iconSize: 24,
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
