class Song {
  final String id;
  final String name;
  final List<String> artists;
  final String album;
  final String image;
  final String? audioUrl;
  final String mood;

  Song({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.image,
    required this.audioUrl,
    required this.mood,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['title'] ?? '').toString(),
      artists: List<String>.from(json['artists'] ?? []),
      album: json['album'] ?? '',
      image: json['image_url'] ?? '',
      audioUrl: json['audio_url'] ?? '', // fallback to empty string
      mood: json['mood'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": name,
      "artists": artists,
      "album": album,
      "image_url": image,
      "audio_url": audioUrl,
      "mood": mood,
    };
  }
}
