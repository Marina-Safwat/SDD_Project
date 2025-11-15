// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class SpotifyService {
//   static const String clientId = '00d9339a74664b5e91c16b531b6547f3';
//   static const String clientSecret = '72f3b5e5095941029a8ecb4e436e16a9';
//   static const String redirectUri = ' smartmusicplayer://callback';

//   String? _accessToken;
//   String? _refreshToken;

//   // Authenticate and get access token
//   Future<bool> authenticate(String code) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://accounts.spotify.com/api/token'),
//         headers: {
//           'Authorization':
//               'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'grant_type': 'authorization_code',
//           'code': code,
//           'redirect_uri': redirectUri,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _accessToken = data['access_token'];
//         _refreshToken = data['refresh_token'];

//         // Save tokens
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('access_token', _accessToken!);
//         await prefs.setString('refresh_token', _refreshToken!);

//         return true;
//       }
//     } catch (e) {
//       print('Authentication error: $e');
//     }
//     return false;
//   }

//   // Load saved token
//   Future<bool> loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _accessToken = prefs.getString('access_token');
//     _refreshToken = prefs.getString('refresh_token');
//     return _accessToken != null;
//   }

//   // Get Currently Playing Track
//   Future<Track?> getCurrentlyPlaying() async {
//     if (_accessToken == null) return null;

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         final data = jsonDecode(response.body);
//         return Track.fromJson(data['item']);
//       }
//     } catch (e) {
//       print('Error getting currently playing: $e');
//     }
//     return null;
//   }

//   // Get User's Playlists
//   Future<List<Playlist>> getUserPlaylists() async {
//     if (_accessToken == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/me/playlists?limit=50'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['items'] as List)
//             .map((item) => Playlist.fromJson(item))
//             .toList();
//       }
//     } catch (e) {
//       print('Error getting playlists: $e');
//     }
//     return [];
//   }

//   // Get Playlist Tracks
//   Future<List<music>> getPlaylistmusics(String playlistId) async {
//     if (_accessToken == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/musics'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['items'] as List)
//             .map((item) => music.fromJson(item['music']))
//             .toList();
//       }
//     } catch (e) {
//       print('Error getting playlist musics: $e');
//     }
//     return [];
//   }

//   // Search musics
//   Future<List<music>> searchmusics(String query) async {
//     if (_accessToken == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.spotify.com/v1/search?q=$query&type=music&limit=20'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['musics']['items'] as List)
//             .map((item) => music.fromJson(item))
//             .toList();
//       }
//     } catch (e) {
//       print('Error searching musics: $e');
//     }
//     return [];
//   }

//   // Get User's Top musics
//   Future<List<music>> getTopmusics() async {
//     if (_accessToken == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/me/top/musics?limit=20'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['items'] as List)
//             .map((item) => music.fromJson(item))
//             .toList();
//       }
//     } catch (e) {
//       print('Error getting top musics: $e');
//     }
//     return [];
//   }

//   // Play music
//   Future<bool> playmusic(String musicUri) async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.put(
//         Uri.parse('https://api.spotify.com/v1/me/player/play'),
//         headers: {
//           'Authorization': 'Bearer $_accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'uris': [musicUri]
//         }),
//       );

//       return response.statusCode == 204;
//     } catch (e) {
//       print('Error playing music: $e');
//     }
//     return false;
//   }

//   // Pause Playback
//   Future<bool> pausePlayback() async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.put(
//         Uri.parse('https://api.spotify.com/v1/me/player/pause'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 204;
//     } catch (e) {
//       print('Error pausing: $e');
//     }
//     return false;
//   }

//   // Resume Playback
//   Future<bool> resumePlayback() async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.put(
//         Uri.parse('https://api.spotify.com/v1/me/player/play'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 204;
//     } catch (e) {
//       print('Error resuming: $e');
//     }
//     return false;
//   }

//   // Next Track
//   Future<bool> nextTrack() async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.post(
//         Uri.parse('https://api.spotify.com/v1/me/player/next'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 204;
//     } catch (e) {
//       print('Error skipping to next: $e');
//     }
//     return false;
//   }

//   // Previous Track
//   Future<bool> previousTrack() async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.post(
//         Uri.parse('https://api.spotify.com/v1/me/player/previous'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 204;
//     } catch (e) {
//       print('Error going to previous: $e');
//     }
//     return false;
//   }

//   // Check if track is saved (liked)
//   Future<bool> isTrackSaved(String trackId) async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/me/tracks/contains?ids=$trackId'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data[0] as bool;
//       }
//     } catch (e) {
//       print('Error checking if track is saved: $e');
//     }
//     return false;
//   }

//   // Save track (like)
//   Future<bool> saveTrack(String trackId) async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.put(
//         Uri.parse('https://api.spotify.com/v1/me/tracks?ids=$trackId'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error saving track: $e');
//     }
//     return false;
//   }

//   // Remove saved track (unlike)
//   Future<bool> removeSavedTrack(String trackId) async {
//     if (_accessToken == null) return false;

//     try {
//       final response = await http.delete(
//         Uri.parse('https://api.spotify.com/v1/me/tracks?ids=$trackId'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error removing saved track: $e');
//     }
//     return false;
//   }

//   // Get User's Saved (Liked) Tracks
//   Future<List<Track>> getSavedTracks() async {
//     if (_accessToken == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse('https://api.spotify.com/v1/me/tracks?limit=50'),
//         headers: {'Authorization': 'Bearer $_accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return (data['items'] as List)
//             .map((item) => Track.fromJson(item['track']))
//             .toList();
//       }
//     } catch (e) {
//       print('Error getting saved tracks: $e');
//     }
//     return [];
//   }
// }
