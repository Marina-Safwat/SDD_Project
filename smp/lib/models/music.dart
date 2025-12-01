import 'package:smp/models/category.dart';
import 'package:smp/models/song.dart';

class Music {
  Category category;
  List<Song> songs;

  Music(this.category, this.songs);

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      Category.fromJson(json['category'] ?? {}),
      (json['songs'] as List<dynamic>? ?? [])
          .map((item) => Song.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "category": category.toJson(),
      "songs": songs.map((s) => s.toJson()).toList(),
    };
  }
}
