import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Song> _filteredSongs = songs; // from data.dart
  String _query = '';

  void _updateSearch(String value) {
    setState(() {
      _query = value.toLowerCase();

      _filteredSongs = songs.where((song) {
        final name = song.name.toLowerCase();
        return name.contains(_query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Search Songs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredSongs.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      return ListTile(
                        leading: song.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  song.image,
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
                          song.name,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          '${song.artist}  •  ${song.description}',
                          style: const TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                        trailing: song.audioURL.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black38,
                                ),
                                onPressed: () {
                                  print('▶ Preview URL: ${song.audioURL}');
                                  // later you connect to your mini-player
                                },
                              )
                            : null,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected Song: ${song.name}'),
                            ),
                          );
                        },
                      );
                      // return ListTile(
                      //   leading: ClipRRect(
                      //     borderRadius: BorderRadius.circular(8),
                      //     child: Image.network(
                      //       song.image,
                      //       width: 50,
                      //       height: 50,
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
                      //   title: Text(song.name),
                      //   onTap: () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         content: Text('Selected Song: ${song.name}'),
                      //       ),
                      //     );
                      //   },
                      // );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
