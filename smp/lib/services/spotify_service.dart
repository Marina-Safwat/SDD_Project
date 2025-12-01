import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smp/models/song.dart';

class SpotifyService {
  static const String clientId = '00d9339a74664b5e91c16b531b6547f3';
  static const String clientSecret = '72f3b5e5095941029a8ecb4e436e16a9';
  static const String redirectUri = 'smartmusicplayer://callback';

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Authenticate using Client Credentials Flow
  Future<bool> authenticate() async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: data['expires_in'] ?? 3600));
        print('✅ Spotify authenticated successfully!');
        return true;
      } else {
        print('❌ Authentication failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Error authenticating: $e');
    }
    return false;
  }

  bool _isTokenValid() {
    if (_accessToken == null || _tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  Future<void> _ensureAuthenticated() async {
    if (!_isTokenValid()) {
      await authenticate();
    }
  }

  /// Convert a Spotify track JSON object into your Music model
  Song _convertToMusic(Map<String, dynamic> track) {
    final artists = ((track['artists'] ?? []) as List)
        .map((a) => a['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');

    final images = (track['album']?['images'] ?? []) as List;
    final imageUrl = images.isNotEmpty ? images[0]['url'] as String : '';

    final albumName = track['album']?['name'] ?? '';

    // audioURL is preview_url when available, otherwise empty string
    final audioUrl = (track['preview_url'] ?? '') as String;

    final mood = _detectMood(track);

    return Song(
      id: "123" + track['name'] ?? '',
      name: track['name'] ?? '',
      artists: [artists],
      image: imageUrl,
      album: albumName,
      audioUrl: audioUrl,
      mood: mood,
    );
  }

  /// Simple mood detection using popularity (quick heuristic)
  String _detectMood(Map<String, dynamic> track) {
    final popularity = track['popularity'] ?? 0;
    if (popularity >= 80) return 'Party';
    if (popularity >= 60) return 'Happy';
    if (popularity >= 40) return 'Chill';
    return 'Peaceful';
  }

  /// Generic search (returns tracks mapped to Music)
  Future<List<Song>> searchTracks(String query, {int limit = 20}) async {
    await _ensureAuthenticated();
    if (_accessToken == null) return [];

    try {
      final encoded = Uri.encodeQueryComponent(query);
      final url =
          'https://api.spotify.com/v1/search?q=$encoded&type=track&market=US&limit=${limit.clamp(1, 50)}';
      final resp = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $_accessToken'});

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final items = (data['tracks']?['items'] ?? []) as List;
        final tracks = items.map((t) => _convertToMusic(t)).toList();
        print('🎧 searchTracks("$query") loaded ${tracks.length} items');
        return tracks;
      } else {
        print('❌ searchTracks failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print('❌ Error in searchTracks: $e');
    }
    return [];
  }

  /// Wrapper: try to fetch Top 50 Global playlist; if it fails (e.g. permission),
  /// fallback to a search query ("top hits") so the app still shows songs.
  Future<List<Song>> getTop50Global({int limit = 20}) async {
    // playlist id for Top 50 Global
    const playlistId = '37i9dQZEVXbMDoHDwVN2tF';
    final playlistTracks = await getPlaylistTracks(playlistId,
        limit: limit, fallbackToSearch: false);
    if (playlistTracks.isNotEmpty) return playlistTracks;

    // fallback search
    print('ℹ Falling back to search "top hits" (playlist failed or empty)');
    return await searchTracks('top hits', limit: limit);
  }

  /// Get tracks from a playlist (tries playlist endpoint; on failure can fallback)
  Future<List<Song>> getPlaylistTracks(String playlistId,
      {int limit = 20, bool fallbackToSearch = true}) async {
    await _ensureAuthenticated();
    if (_accessToken == null) return [];

    try {
      final url = Uri.parse(
          'https://api.spotify.com/v1/playlists/$playlistId/tracks?market=US&limit=50');
      final resp = await http
          .get(url, headers: {'Authorization': 'Bearer $_accessToken'});

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final items = (data['items'] ?? []) as List;
        final tracks = items
            .where((it) => it != null && it['track'] != null)
            .map((it) => _convertToMusic(it['track']))
            .take(limit)
            .toList();
        print('🎵 Playlist $playlistId loaded ${tracks.length} tracks');
        return tracks;
      } else {
        // If playlist endpoint returns 404 or other (no permission), optionally fallback
        print(
            '❌ Playlist fetch failed (status ${resp.statusCode}). Body: ${resp.body}');
        if (fallbackToSearch) {
          // try a search fallback
          return await searchTracks('top hits', limit: limit);
        }
      }
    } catch (e) {
      print('❌ Error fetching playlist tracks: $e');
      if (fallbackToSearch) {
        return await searchTracks('top hits', limit: limit);
      }
    }

    return [];
  }

  /// Optional: get track details by id (useful if you want to call audio features)
  Future<Song?> getTrackDetails(String trackId) async {
    await _ensureAuthenticated();
    if (_accessToken == null) return null;
    try {
      final url =
          Uri.parse('https://api.spotify.com/v1/tracks/$trackId?market=US');
      final resp = await http
          .get(url, headers: {'Authorization': 'Bearer $_accessToken'});
      if (resp.statusCode == 200) {
        final track = jsonDecode(resp.body) as Map<String, dynamic>;
        return _convertToMusic(track);
      }
    } catch (e) {
      print('❌ Error getTrackDetails: $e');
    }
    return null;
  }

  /// Map moods → best search queries
  String _moodToQuery(String mood) {
    final map = {
      'happy': 'happy upbeat pop',
      'sad': 'sad emotional',
      'chill': 'lofi chill relax',
      'energetic': 'energetic workout pop',
      'romantic': 'romantic love songs',
      'angry': 'angry rock metal',
      'peaceful': 'relax calm ambient',
      'party': 'party dance edm',
      'motivational': 'motivational inspire',
      'nostalgic': 'nostalgic throwback',
    };
    return map[mood.toLowerCase()] ?? mood;
  }

  /// 🎵 **MAIN FEATURE** → FETCH SONGS BASED ON MOOD
  Future<List<Song>> getTracksByMood(String mood, {int limit = 20}) async {
    final query = _moodToQuery(mood);
    print("🔎 Searching Spotify for mood: $mood → '$query'");
    return await searchTracks(query, limit: limit);
  }
}
