import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(SmartMusicPlayer());
}

class SmartMusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1a1a2e),
      ),
      home: PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;
  bool isLoading = false;
  String? currentSongName;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double volume = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        isLoading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        totalDuration = duration ?? Duration.zero;
      });
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return;
    }
    if (await Permission.audio.request().isGranted) {
      return;
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      await _requestPermissions();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        setState(() {
          currentSongName = fileName;
          isLoading = true;
        });

        await _audioPlayer.setFilePath(filePath);
        await _audioPlayer.play();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playing: $fileName')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void _changeVolume(double value) {
    setState(() {
      volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Music Player'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note,
                size: 120,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            SizedBox(height: 40),

            // Song Title
            Text(
              currentSongName ?? 'No song selected',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 10),

            Text(
              'Unknown Artist',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            SizedBox(height: 40),

            // Progress Bar
            Column(
              children: [
                Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  max: totalDuration.inSeconds.toDouble() > 0
                      ? totalDuration.inSeconds.toDouble()
                      : 1.0,
                  onChanged: (value) {
                    _seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey.shade800,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(currentPosition),
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous Button
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 45,
                  color: Colors.white,
                  onPressed: () {
                    _seek(Duration.zero);
                  },
                ),

                // Play/Pause Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: currentSongName != null
                        ? _togglePlayPause
                        : null,
                  ),
                ),

                // Next Button
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 45,
                  color: Colors.white,
                  onPressed: () {
                    // Placeholder for next song
                  },
                ),
              ],
            ),

            SizedBox(height: 30),

            // Volume Control
            Row(
              children: [
                Icon(Icons.volume_down, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: _changeVolume,
                    activeColor: Colors.purple,
                    inactiveColor: Colors.grey.shade800,
                  ),
                ),
                Icon(Icons.volume_up, color: Colors.grey),
              ],
            ),

            SizedBox(height: 20),

            // Pick File Button
            ElevatedButton.icon(
              onPressed: _pickAudioFile,
              icon: Icon(Icons.library_music),
              label: Text('Select Music File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
