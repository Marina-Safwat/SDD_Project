import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/models/song.dart';
import 'package:smp/services/apiService.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  late Future<HistorySongResponse> _likedFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _likedFuture =
          Future.value(HistorySongResponse(success: false, songs: []));
    } else {
      // for now we reuse history as liked source
      _likedFuture = ApiService.fetchHistory(userId: user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked songs'),
        centerTitle: true,
      ),
      body: FutureBuilder<HistorySongResponse>(
        future: _likedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load liked songs.'));
          }

          final data = snapshot.data;
          final songs = data?.songs ?? [];

          if (!(data?.success ?? false) || songs.isEmpty) {
            return const Center(
                child: Text('You have not liked any songs yet.'));
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
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
                    : const Icon(Icons.music_note),
                title: Text(song.name),
                subtitle: Text(song.artists.join(', ')),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${song.name}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
