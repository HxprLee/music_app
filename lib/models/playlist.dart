class Playlist {
  final String id;
  final String name;
  final List<String> songPaths;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songPaths,
    required this.createdAt,
  });

  Playlist copyWith({String? name, List<String>? songPaths}) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      songPaths: songPaths ?? this.songPaths,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songPaths': songPaths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      songPaths: List<String>.from(json['songPaths']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
