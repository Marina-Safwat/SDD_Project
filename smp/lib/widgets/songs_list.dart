import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';

class SongsList extends StatelessWidget {
  const SongsList({super.key, required this.tracks});

  final List<Song> tracks;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (ctx, index) {
        final track = tracks[index];

        return ListTile(
          leading: track.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    track.image,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.music_note,
                  color: Colors.black87,
                ),
          title: Text(
            track.name,
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${track.artist}  •  ${track.description}',
            style: const TextStyle(
              color: Colors.black38,
            ),
          ),
          trailing: track.audioURL.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.black38,
                  ),
                  onPressed: () {
                    print('▶ Preview URL: ${track.audioURL}');
                    // later you connect to your mini-player
                  },
                )
              : null,
        );
      },
    );
  }
}
