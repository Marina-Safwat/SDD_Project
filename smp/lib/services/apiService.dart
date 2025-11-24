import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smp/models/song.dart';
import 'package:flutter/foundation.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// API Response wrapper for type-safe responses
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

/// Main API Service for Digital Ocean Backend
class ApiService {
  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const String baseUrl = 'https://smp-app-afy4g.ondigitalocean.app';
  static const String apiKey = 'c347a711-9dd0-484a-9902-45d5d45da6a6';
  static const Duration timeout = Duration(seconds: 30);

  // Enable/disable detailed logging
  static bool enableLogging = true;

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

  /// Generic GET request with error handling
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
      _log('❌ Network Error: $e');
      throw ApiException('Network error occurred', error: e);
    } on FormatException catch (e) {
      _log('❌ JSON Parse Error: $e');
      throw ApiException('Invalid response format', error: e);
    } catch (e) {
      _log('❌ Unexpected Error: $e');
      throw ApiException('An unexpected error occurred', error: e);
    }
  }

  // ============================================================
  // CONNECTION TEST
  // ============================================================

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      _log('🔌 Testing API connection...');
      final response = await fetchPlaylist(mood: 'happy', limit: 1);
      _log('✅ API connection successful');
      return response.success && (response.data?.isNotEmpty ?? false);
    } catch (e) {
      _log('❌ API connection failed: $e');
      return false;
    }
  }

  // ============================================================
  // MOOD MANAGEMENT
  // ============================================================

  /// Update user's current mood on the backend
  static Future<ApiResponse<bool>> updateUserMood(
    String userId,
    String mood,
  ) async {
    try {
      _log('🎭 Updating user mood: $userId -> $mood');

      // Validate mood first
      if (!isValidMood(mood)) {
        return ApiResponse.failure('Invalid mood: $mood');
      }

      final endpoint = '/update-mood/$apiKey/$userId/${mood.toLowerCase()}';
      final data = await _getRequest(endpoint);

      if (data['success'] == true) {
        _log('✅ Mood updated successfully: $mood');
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

  /// Fetch playlist by mood - Main method to get songs
  static Future<ApiResponse<List<Song>>> fetchPlaylist({
    required String mood,
    int limit = 10,
  }) async {
    try {
      _log('🎧 Fetching playlist for mood: $mood (limit: $limit)');

      final data = await _getRequest('/playlist/$apiKey/$mood/$limit');

      if (data['success'] == true && data['result'] != null) {
        final results = data['result'] as List;
        final songs = results.map((item) => Song.fromJson(item)).toList();

        _log('✅ Fetched ${songs.length} songs');
        return ApiResponse.success(songs);
      } else {
        return ApiResponse.failure('No songs found for mood: $mood');
      }
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (e) {
      return ApiResponse.failure('Failed to fetch playlist: $e');
    }
  }

  /// Get tracks by mood - Alias for fetchPlaylist (matches Spotify service interface)
  static Future<List<Song>> getTracksByMood(String mood,
      {int limit = 20}) async {
    _log('🔎 Getting tracks for mood: $mood');
    final response = await fetchPlaylist(mood: mood, limit: limit);
    return response.data ?? [];
  }

  // ============================================================
  // NEXT SONG
  // ============================================================

  /// Get next song based on user preferences and history
  static Future<ApiResponse<Song>> nextSong(String userId, String mood) async {
    try {
      _log('⏭️ Fetching next song for user: $userId, mood: $mood');

      final data = await _getRequest('/next-song/$apiKey/$userId/$mood');

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

  /// Skip current song
  static Future<ApiResponse<bool>> skipSong(
    String userId,
    String songId,
    String mood,
  ) async {
    return _performAction('skip-song', userId, songId, mood);
  }

  /// Mark song as finished (completed playback)
  static Future<ApiResponse<bool>> finishSong(
    String userId,
    String songId,
    String mood,
  ) async {
    return _performAction('finish-song', userId, songId, mood);
  }

  /// Like/unlike a song
  static Future<ApiResponse<bool>> likeSong(
    String userId,
    String songId,
    String mood,
    bool like,
  ) async {
    return _performAction('like-song', userId, songId, mood, value: like);
  }

  /// Dislike/undislike a song
  static Future<ApiResponse<bool>> dislikeSong(
    String userId,
    String songId,
    String mood,
    bool dislike,
  ) async {
    return _performAction('dislike-song', userId, songId, mood, value: dislike);
  }

  /// Favorite/unfavorite a song
  static Future<ApiResponse<bool>> favoriteSong(
    String userId,
    String songId,
    String mood,
    bool favorite,
  ) async {
    return _performAction('favorite-song', userId, songId, mood,
        value: favorite);
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Perform user action (like, skip, etc.)
  static Future<ApiResponse<bool>> _performAction(
    String action,
    String userId,
    String songId,
    String mood, {
    bool? value,
  }) async {
    try {
      final endpoint = value != null
          ? '/$action/$apiKey/$userId/$songId/$mood/${value ? 1 : 0}'
          : '/$action/$apiKey/$userId/$songId/$mood';

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
    'text',
  ];

  /// Check if mood is valid
  static bool isValidMood(String mood) {
    return availableMoods.contains(mood.toLowerCase());
  }

  /// Get mood display name (capitalize first letter)
  static String getMoodDisplayName(String mood) {
    if (mood.isEmpty) return mood;
    return mood[0].toUpperCase() + mood.substring(1).toLowerCase();
  }

  // ============================================================
  // SPOTIFY CONVERSION (if needed for migration)
  // ============================================================

  /// Convert Spotify track to Song model (useful if you have Spotify data)
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
      id: int.tryParse(track['id']?.toString() ?? '') ?? 0,
      name: track['name']?.toString() ?? '',
      artists: artists,
      album: albumName,
      image: imageUrl,
      audioUrl: audioUrl,
      mood: '',
    );
  }
}

// ============================================================
// USAGE EXAMPLES
// ============================================================

/// Example usage of ApiService
class ApiServiceExamples {
  /// Example: Test connection
  static Future<void> testConnection() async {
    final isConnected = await ApiService.testConnection();
    print('Connected: $isConnected');
  }

  /// Example: Update user mood
  static Future<void> updateMood() async {
    final response = await ApiService.updateUserMood('user_123', 'happy');
    if (response.success) {
      print('Mood updated!');
    } else {
      print('Error: ${response.error}');
    }
  }

  /// Example: Get songs by mood
  static Future<void> getSongs() async {
    final response = await ApiService.fetchPlaylist(mood: 'happy', limit: 10);
    if (response.success) {
      print('Got ${response.data!.length} songs');
      for (var song in response.data!) {
        print('- ${song.name} by ${song.artists.join(", ")}');
      }
    } else {
      print('Error: ${response.error}');
    }
  }

  /// Example: Like a song
  static Future<void> likeSong() async {
    final response = await ApiService.likeSong(
      'user_123',
      'song_id_here',
      'happy',
      true,
    );
    print('Liked: ${response.success}');
  }

  /// Example: Get next song
  static Future<void> getNext() async {
    final response = await ApiService.nextSong('user_123', 'happy');
    if (response.success && response.data != null) {
      print('Next song: ${response.data!.name}');
    }
  }
}
