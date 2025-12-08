class Song {
  final String path;
  final String title;
  final String artist;
  final String? album;
  final bool hasAlbumArt; // Lightweight flag instead of storing bytes
  final String? lyrics;
  final Duration? duration;

  Song({
    required this.path,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album,
    this.hasAlbumArt = false,
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
    bool? hasAlbumArt,
    String? lyrics,
    Duration? duration,
  }) {
    return Song(
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      hasAlbumArt: hasAlbumArt ?? this.hasAlbumArt,
      lyrics: lyrics ?? this.lyrics,
      duration: duration ?? this.duration,
    );
  }
}
