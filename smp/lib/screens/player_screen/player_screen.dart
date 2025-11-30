import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smp/models/song.dart';

class PlayerScreen__ extends StatefulWidget {
  final Song song;

  const PlayerScreen__({
    super.key,
    required this.song,
  });

  @override
  State<PlayerScreen__> createState() => _PlayerScreen__State();
}

class _PlayerScreen__State extends State<PlayerScreen__> {
  late final AudioPlayer _player;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = widget.song.audioUrl;
    //final url = widget.song.audioUrl;

    if (url == null || url.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      await _player.setUrl(url);
      await _player.play(); // auto play when screen opens
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now playing'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Artwork
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: song.image.isNotEmpty
                        ? Image.network(
                            song.image,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.music_note,
                              size: 80,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title + artists + album
            Text(
              song.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              song.artists.join(', '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (song.album.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                song.album,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 24),

            if (_isLoading)
              const CircularProgressIndicator()
            else if (_hasError)
              const Text(
                'No preview available for this track.',
                textAlign: TextAlign.center,
              )
            else ...[
              // ==== PROGRESS BAR + TIME ====
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;

                  final totalMs = total.inMilliseconds.toDouble();
                  final posMs = position.inMilliseconds.toDouble().clamp(
                        0,
                        totalMs > 0 ? totalMs : double.infinity,
                      );

                  return Column(
                    children: [
                      Slider(
                        value: totalMs > 0 ? posMs.toDouble() : 0,
                        max: totalMs > 0 ? totalMs : 1,
                        onChanged: totalMs > 0
                            ? (value) {
                                _player.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _formatDuration(total),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // ==== PLAYBACK CONTROLS ====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: null, // later: connect to queue
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: _togglePlayPause,
                    child: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next),
                    onPressed: null, // later: connect to queue
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
