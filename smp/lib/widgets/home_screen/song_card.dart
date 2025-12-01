import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';
import 'package:smp/screens/player_screen/playerScreen.dart';
import 'package:smp/screens/player_screen/player_screen.dart';

class SongCard extends StatelessWidget {
  final Song song;
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
        onTap(song);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => PlayerScreen__(
        //       song: song,
        //     ),
        //   ),
        //);
        // TODO: navigate to a song detail / player screen
        // Navigator.push(...);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
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
            // Song name
            Text(
              song.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // Artists
            Text(
              song.artists.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // Album
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
