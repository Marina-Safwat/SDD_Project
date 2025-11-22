import 'package:smp/models/category.dart';
import 'package:smp/models/song.dart';

class Music {
  Category category;
  List<Song> songs;
  Music(this.category, this.songs);
}
