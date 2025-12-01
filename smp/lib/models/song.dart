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
      
      // Support multiple API field formats
      image: json['image_url'] ??
             json['image'] ??
             '',
             
      audioUrl: json['audio_url'] ??
                json['audio'] ??
                '',
                
      mood: json['mood'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": name,
      "artists": artists,
      "album": album,
      
      // Always write the primary key format
      "image_url": image,
      "audio_url": audioUrl,
      
      "mood": mood,
    };
  }
}
