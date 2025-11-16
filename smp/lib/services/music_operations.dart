import 'package:smp/models/music.dart';

class MusicOperations {
  MusicOperations._() {}
  static List<Music> getMusic() {
    return <Music>[
      Music(
          'Feather',
          'Sabrina Carpenter',
          'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
          'Sabrina',
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
          'happy'),
      Music(
          'test',
          'Sabrina Carpenter',
          'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
          'tester',
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
          'happy'),
      Music(
          'Feather',
          'Sabrina Carpenter',
          'https://m.media-amazon.com/images/I/41E7kviZxcL._SX466_.jpg',
          'Sabrina',
          'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b6/05/90/b60590c7-94f4-275e-2586-bc1e44d90333/mzaf_15460092183646897234.plus.aac.p.m4a',
          'happy'),
    ];
  }
}
