import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smp/data/data.dart';
import 'package:smp/models/song.dart';

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Generic API response wrapper for type-safe results.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.failure(this.error)
      : success = false,
        data = null;
}

/// Response model for search songs.
class SearchSongResponse {
  final bool success;
  final List<Song> songs;

  SearchSongResponse({required this.success, required this.songs});

  factory SearchSongResponse.fromJson(Map<String, dynamic> json) {
    final results = json['result'] as List? ?? [];
    final songs = results.map((e) => Song.fromJson(e)).toList();
    return SearchSongResponse(
      success: json['success'] == true,
      songs: songs,
    );
  }
}

class LikedSongsResponse {
  final bool success;
  final List<Song> songs;

  LikedSongsResponse({
    required this.success,
    required this.songs,
  });

  factory LikedSongsResponse.fromJson(Map<String, dynamic> json) {
    // 👇 Safely read the list from "result"
    final raw = json['result'];

    if (raw is! List) {
      // Optional: you can log here
      // debugPrint('LikedSongsResponse: "result" is not a List: $raw');
      return LikedSongsResponse(
        success: json['success'] == true,
        songs: [],
      );
    }

    // 👇 Only keep items that are actually Map<String, dynamic>
    final songs = raw
        .where((item) => item is Map<String, dynamic>)
        .map((item) => Song.fromJson(item as Map<String, dynamic>))
        .toList();

    return LikedSongsResponse(
      success: json['success'] == true,
      songs: songs,
    );
  }
}

//for liked songs class LikedSongsResponse {
// class LikedSongsResponse {
//   final bool success;
//   final List<Song> songs;

//   LikedSongsResponse({required this.success, required this.songs});

//   factory LikedSongsResponse.fromJson(Map<String, dynamic> json) {
//     final results = json['result'] as List<dynamic>? ?? [];
//     final songs = results.map((item) => Song.fromJson(item)).toList();
//     return LikedSongsResponse(
//       success: json['success'] == true,
//       songs: songs,
//     );
//   }
// }

/// Response model for history songs.
class HistorySongResponse {
  final bool success;
  final List<Song> songs;

  HistorySongResponse({required this.success, required this.songs});

  factory HistorySongResponse.fromJson(Map<String, dynamic> json) {
    final results = json['result'] as List<dynamic>? ?? [];
    final songs = results.map((item) => Song.fromJson(item)).toList();
    return HistorySongResponse(
      success: json['success'] == true,
      songs: songs,
    );
  }
}

/// Main API Service for Digital Ocean backend.
class ApiService {
  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const String baseUrl = 'https://smp-app-afy4g.ondigitalocean.app';
  static const String apiKey = 'c347a711-9dd0-484a-9902-45d5d45da6a6';
  static const Duration timeout = Duration(seconds: 30);

  /// Enable/disable detailed logging.
  static bool enableLogging = true;
  static List<Song> localSongs = [
    testSong0,
    testSong1,
    testSong2,
    testSong3,
    testSong4,
    testSong5,
    testSong6
  ];
  // ============================================================
  // LOGGING
  // ============================================================

  static void _log(String message) {
    if (enableLogging) {
      debugPrint(message);
    }
  }

  // ============================================================
  // CORE HTTP METHODS
  // ============================================================

  /// Generic GET request with error handling.
  static Future<Map<String, dynamic>> _getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    _log('📡 GET Request: $url');

    try {
      final response = await http.get(url).timeout(timeout);

      _log('📥 Response Status: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw ApiException(
          'Server returned error',
          statusCode: response.statusCode,
          error: response.body,
        );
      }
    } on http.ClientException catch (e) {
      _log(' Network Error: $e');
      throw ApiException('Network error occurred', error: e);
    } on FormatException catch (e) {
      _log(' JSON Parse Error: $e');
      throw ApiException('Invalid response format', error: e);
    } catch (e) {
      _log(' Unexpected Error: $e');
      throw ApiException('An unexpected error occurred', error: e);
    }
  }

  // ============================================================
  // CONNECTION TEST
  // ============================================================

  /// Test API connection by fetching a small playlist.
  static Future<bool> testConnection() async {
    try {
      _log('🔌 Testing API connection...');
      final response = await fetchPlaylist(mood: 'happy', limit: 1);
      _log('✅ API connection successful');
      return response.success;
    } catch (e) {
      _log(' API connection failed: $e');
      return false;
    }
  }

  // ============================================================
  // MOOD MANAGEMENT
  // ============================================================

  /// Update user's current mood on the backend.
  static Future<ApiResponse<bool>> updateUserMood(
    String userId,
    String mood,
  ) async {
    try {
      _log('🎭 Updating user mood: $userId -> $mood');

      // Validate mood first.
      if (!isValidMood(mood)) {
        return ApiResponse.failure('Invalid mood: $mood');
      }

      final normalizedMood = mood.toLowerCase();
      final endpoint = '/update-mood/$apiKey/$userId/$normalizedMood';
      final data = await _getRequest(endpoint);

      if (data['success'] == true) {
        _log('✅ Mood updated successfully: $normalizedMood');
        return ApiResponse.success(true);
      } else {
        return ApiResponse.failure('Failed to update mood');
      }
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (e) {
      return ApiResponse.failure('Failed to update mood: $e');
    }
  }

  // ============================================================
  // FETCH SONGS
  // ============================================================

  /// Fetch playlist by mood - main method to get songs.
  static Future<ApiResponse<List<Song>>> fetchPlaylist({
    required String mood,
    int limit = 10,
  }) async {
    try {
      final normalizedMood = mood.toLowerCase();
      _log('🎧 Fetching playlist for mood: $normalizedMood (limit: $limit)');

      final data =
          await _getRequest('/playlist/$apiKey/$normalizedMood/$limit');

      if (data['success'] == true && data['result'] != null) {
        final results = data['result'] as List;
        final songs = results.map((item) => Song.fromJson(item)).toList();
        // final songs = [...localSongs, ...apisongs].toList();
        _log('✅ Fetched ${songs.length} songs');
        return ApiResponse.success(songs);
      } else {
        return ApiResponse.failure(
          'No songs found for mood: $normalizedMood',
        );
      }
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (e) {
      return ApiResponse.failure('Failed to fetch playlist: $e');
    }
  }

  /// Get tracks by mood - alias for [fetchPlaylist] (matches Spotify service interface).
  static Future<List<Song>> getTracksByMood(
    String mood, {
    int limit = 20,
  }) async {
    _log('🔎 Getting tracks for mood: $mood');
    final response = await fetchPlaylist(mood: mood, limit: limit);
    return response.data ?? [];
  }

  // ============================================================
  // NEXT SONG
  // ============================================================

  /// Get next song based on user preferences and history.
  static Future<ApiResponse<Song>> nextSong(
    String userId,
    String mood,
  ) async {
    try {
      final normalizedMood = mood.toLowerCase();
      _log('⏭️ Fetching next song for user: $userId, mood: $normalizedMood');

      final data =
          await _getRequest('/next-song/$apiKey/$userId/$normalizedMood');

      if (data['success'] == true && data['result'] != null) {
        final song = Song.fromJson(data['result']);
        _log('✅ Next song: ${song.name}');
        return ApiResponse.success(song);
      } else {
        return ApiResponse.failure('No next song available');
      }
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (e) {
      return ApiResponse.failure('Failed to fetch next song: $e');
    }
  }

  // ============================================================
  // USER ACTIONS
  // ============================================================

  /// Skip current song.
  static Future<ApiResponse<bool>> skipSong(
    String userId,
    String songId,
    String mood,
  ) async {
    return _performAction('skip-song', userId, songId, mood);
  }

  /// Mark song as finished (completed playback).
  static Future<ApiResponse<bool>> finishSong(
    String userId,
    String songId,
    String mood,
  ) async {
    return _performAction('finish-song', userId, songId, mood);
  }

  /// Like/unlike a song.
  static Future<ApiResponse<bool>> likeSong(
    String userId,
    String songId,
    String mood,
    bool like,
  ) async {
    return _performAction(
      'like-song',
      userId,
      songId,
      mood,
      value: like,
    );
  }

  /// Dislike/undislike a song.
  static Future<ApiResponse<bool>> dislikeSong(
    String userId,
    String songId,
    String mood,
    bool dislike,
  ) async {
    return _performAction(
      'dislike-song',
      userId,
      songId,
      mood,
      value: dislike,
    );
  }

  /// Favorite/unfavorite a song.
  static Future<ApiResponse<bool>> favoriteSong(
    String userId,
    String songId,
    String mood,
    bool favorite,
  ) async {
    return _performAction(
      'favorite-song',
      userId,
      songId,
      mood,
      value: favorite,
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Perform user action (like, skip, etc.).
  static Future<ApiResponse<bool>> _performAction(
    String action,
    String userId,
    String songId,
    String mood, {
    bool? value,
  }) async {
    try {
      final normalizedMood = mood.toLowerCase();

      final endpoint = value != null
          ? '/$action/$apiKey/$userId/$songId/$normalizedMood/${value ? 1 : 0}'
          : '/$action/$apiKey/$userId/$songId/$normalizedMood';

      _log('🎯 Performing action: $action');
      final data = await _getRequest(endpoint);

      if (data['success'] == true) {
        _log('✅ Action successful: $action');
        return ApiResponse.success(true);
      } else {
        return ApiResponse.failure('Action failed: $action');
      }
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (e) {
      return ApiResponse.failure('Failed to perform action: $e');
    }
  }

  // ============================================================
  // AVAILABLE MOODS
  // ============================================================

  /// List of backend-supported moods (lowercase).
  static const List<String> availableMoods = [
    'happy',
    'sad',
    'chill',
    'energetic',
    'romantic',
    'angry',
    'peaceful',
    'party',
    'motivational',
    'nostalgic',
  ];

  /// Check if mood is valid.
  static bool isValidMood(String mood) {
    return availableMoods.contains(mood.toLowerCase());
  }

  /// Get mood display name (capitalize first letter).
  static String getMoodDisplayName(String mood) {
    if (mood.isEmpty) return mood;
    return mood[0].toUpperCase() + mood.substring(1).toLowerCase();
  }

  // ============================================================
  // SPOTIFY CONVERSION (if needed for migration)
  // ============================================================

  /// Convert Spotify track to [Song] model (useful if you have Spotify data).
  static Song spotifyTrackToSong(Map<String, dynamic> track) {
    final artists = (track['artists'] as List<dynamic>? ?? [])
        .map((a) => a['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final images = (track['album']?['images'] ?? []) as List<dynamic>;
    final imageUrl = images.isNotEmpty ? images[0]['url'] as String : '';
    final albumName = track['album']?['name']?.toString() ?? '';
    final audioUrl = track['preview_url']?.toString() ?? '';

    return Song(
      id: track['id']?.toString() ?? '',
      name: track['name']?.toString() ?? '',
      artists: artists,
      album: albumName,
      image: imageUrl,
      audioUrl: audioUrl,
      mood: '',
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  /// Search songs by query and mood.
  static Future<SearchSongResponse> searchSongs({
    required String query,
    required String mood,
    int limit = 10,
  }) async {
    try {
      final normalizedMood = mood.toLowerCase();
      final encodedQuery = Uri.encodeComponent(query);

      _log('🔍 Searching songs: "$query" mood: $normalizedMood');

      final endpoint = '/search/$apiKey/$encodedQuery/$limit/$normalizedMood';
      final data = await _getRequest(endpoint);

      return SearchSongResponse.fromJson(data);
    } on ApiException catch (e) {
      _log(' Search API error: ${e.message}');
      return SearchSongResponse(success: false, songs: []);
    } catch (e) {
      _log(' Unexpected Search API error: $e');
      return SearchSongResponse(success: false, songs: []);
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  /// Fetch user listening history.
  static Future<HistorySongResponse> fetchHistory({
    required String userId,
  }) async {
    try {
      final endpoint = '/history/$apiKey/$userId';
      final data = await _getRequest(endpoint);
      return HistorySongResponse.fromJson(data);
    } on ApiException catch (e) {
      _log(' History API error: ${e.message}');
      return HistorySongResponse(success: false, songs: []);
    } catch (e) {
      _log(' Unexpected History API error: $e');
      return HistorySongResponse(success: false, songs: []);
    }
  }
  // ============================================================
  // LIKED SONGS
  // ============================================================

  /// Fetch user listening history.
  static Future<LikedSongsResponse> fetchLikedSongs({
    required String userId,
  }) async {
    try {
      _log('💖 Fetching liked songs for user: $userId');

      final endpoint = '/liked/$apiKey/$userId';
      final data = await _getRequest(endpoint);

      final response = LikedSongsResponse.fromJson(data);
      _log('✅ Fetched ${response.songs.length} liked songs');

      return response;
    } on ApiException catch (e) {
      _log('❌ Liked Songs API error: ${e.message}');
      return LikedSongsResponse(success: false, songs: []);
    } catch (e) {
      _log('❌ Unexpected Liked Songs API error: $e');
      return LikedSongsResponse(success: false, songs: []);
    }
  }
}

// ============================================================
// USAGE EXAMPLES (not used in app flow, but handy for testing)
// ============================================================

class ApiServiceExamples {
  /// Example: Test connection.
  static Future<void> testConnection() async {
    final isConnected = await ApiService.testConnection();
    print('Connected: $isConnected');
  }

  /// Example: Update user mood.
  static Future<void> updateMood() async {
    final response = await ApiService.updateUserMood('user_123', 'happy');
    if (response.success) {
      print('Mood updated!');
    } else {
      print('Error: ${response.error}');
    }
  }

  /// Example: Get songs by mood.
  static Future<void> getSongs() async {
    final response = await ApiService.fetchPlaylist(mood: 'happy', limit: 10);
    if (response.success && response.data != null) {
      print('Got ${response.data!.length} songs');
      for (var song in response.data!) {
        print('- ${song.name} by ${song.artists.join(", ")}');
      }
    } else {
      print('Error: ${response.error}');
    }
  }

  /// Example: Like a song.
  static Future<void> likeSong() async {
    final response = await ApiService.likeSong(
      'user_123',
      'song_id_here',
      'happy',
      true,
    );
    print('Liked: ${response.success}');
  }

  /// Example: Get next song.
  static Future<void> getNext() async {
    final response = await ApiService.nextSong('user_123', 'happy');
    if (response.success && response.data != null) {
      print('Next song: ${response.data!.name}');
    }
  }
}
