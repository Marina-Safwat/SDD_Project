import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';

/// A reusable card widget for displaying a single [Song].
///
/// This widget is deliberately kept "dumb":
/// - It ONLY displays the UI for a song (image, title, artist, album).
/// - It does NOT handle navigation or audio playback directly.
/// - Instead, it calls the [onTap] callback and lets the parent widget
///   (e.g., TabsScreen / MoodHomeScreen) decide what to do
///   (open PlayerScreen, start audio, show mini player, etc.).
class SongCard extends StatelessWidget {
  /// The song to display.
  final Song song;

  /// Callback invoked when the card is tapped.
  ///
  /// We pass the [song] back to the parent so it can:
  /// - Start or update the AudioPlayer
  /// - Navigate to PlayerScreen
  /// - Update mini-player state
  /// - Track analytics, history, etc.
  final void Function(Song) onTap;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // ✅ Delegate all behavior to the parent.
        // This keeps SongCard purely presentational.
        onTap(song);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // Cover image
            // =========================
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1, // square cover
                child: Image.network(
                  song.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // =========================
            // Song title
            // =========================
            Text(
              song.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // =========================
            // Artists
            // =========================
            Text(
              song.artists.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),

            // =========================
            // Album name
            // =========================
            Text(
              song.album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
