import 'package:smp/models/category.dart';
import 'package:smp/models/song.dart';

class Music {
  final Category category;
  final List<Song> songs;
  Music({required this.category, required this.songs});
}
