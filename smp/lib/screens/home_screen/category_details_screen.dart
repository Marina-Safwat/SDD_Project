import 'package:flutter/material.dart';
import 'package:smp/models/music.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final Music music;

  const CategoryDetailsScreen({
    super.key,
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(music.category.name),
      ),
      body: ListView.builder(
        itemCount: music.songs.length,
        itemBuilder: (context, index) {
          final item = music.songs[index];
          return ListTile(
            leading: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.image,
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
              item.name,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Text(
              '${item.artists.join(', ')}  •  ${item.album}',
              style: const TextStyle(
                color: Colors.black38,
              ),
            ),
            trailing: item.audioUrl?.isNotEmpty == true
                ? IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.black38,
                    ),
                    onPressed: () {
                      print('▶ Preview URL: ${item.audioUrl}');
                      // later you connect to your mini-player
                    },
                  )
                : null,
            onTap: () {
              // Optional: handle tap on each card
              // e.g., navigate to another detail screen
            },
          );
        },
      ),
    );
  }
}
