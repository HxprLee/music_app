import 'dart:typed_data';

class Song {
  final String path;
  final String title;
  final String artist;
  final String? album;
  final Uint8List? albumArt;
  final String? lyrics;
  final Duration? duration;

  Song({
    required this.path,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album,
    this.albumArt,
    this.lyrics,
    this.duration,
  });

  // Extract title from filename
  factory Song.fromPath(String path) {
    final fileName = path.split('/').last;
    final titleWithoutExt = fileName.split('.').first;

    return Song(path: path, title: titleWithoutExt, artist: 'Unknown Artist');
  }

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    Uint8List? albumArt,
    String? lyrics,
    Duration? duration,
  }) {
    return Song(
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      lyrics: lyrics ?? this.lyrics,
      duration: duration ?? this.duration,
    );
  }
}
