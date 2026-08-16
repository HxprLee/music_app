// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/library_models.dart';

class LocalSearchService {
  static bool _matches(String query, String text) {
    if (query.isEmpty) return true;
    final tokens = query.toLowerCase().trim().split(RegExp(r'\s+'));
    final t = text.toLowerCase();
    return tokens.every((token) => t.contains(token));
  }

  static List<Song> searchSongs(String query, List<Song> songs) {
    if (query.isEmpty) return [];
    return songs.where((song) {
      return _matches(query, '${song.title} ${song.artist} ${song.album ?? ""}');
    }).toList();
  }

  static List<Playlist> searchPlaylists(String query, List<Playlist> playlists) {
    if (query.isEmpty) return [];
    return playlists.where((p) => _matches(query, p.name)).toList();
  }

  static List<Album> searchAlbums(String query, List<Album> albums) {
    if (query.isEmpty) return [];
    return albums.where((a) => _matches(query, '${a.name} ${a.artist}')).toList();
  }

  static List<Artist> searchArtists(String query, List<Artist> artists) {
    if (query.isEmpty) return [];
    return artists.where((a) => _matches(query, a.name)).toList();
  }

  static List<String> searchFolders(String query, List<Song> allSongs) {
    if (query.isEmpty) return [];
    final dirs = allSongs
        .where((song) => !song.path.startsWith('yt:'))
        .map((s) => s.path.substring(0, s.path.lastIndexOf('/')))
        .where((dir) => _matches(query, dir))
        .toSet()
        .toList()
          ..sort();
    return dirs;
  }
}
