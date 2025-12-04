import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class SongCache {
  static const String _cacheFileName = 'song_cache.json';
  static const String _artDirName = 'album_art';

  static Future<String> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/music_app_cache';
  }

  static Future<String> get _artDir async {
    final cache = await _cacheDir;
    return '$cache/$_artDirName';
  }

  static Future<String> get _cacheFilePath async {
    final cache = await _cacheDir;
    return '$cache/$_cacheFileName';
  }

  /// Initialize cache directories
  static Future<void> init() async {
    final cacheDir = Directory(await _cacheDir);
    final artDir = Directory(await _artDir);

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    if (!await artDir.exists()) {
      await artDir.create(recursive: true);
    }
  }

  /// Generate a unique filename for album art based on song path
  static String _artFileName(String songPath) {
    return '${songPath.hashCode.abs()}.jpg';
  }

  /// Load all cached songs
  static Future<List<Song>> loadCache() async {
    try {
      final file = File(await _cacheFilePath);
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      final artDirPath = await _artDir;

      final songs = <Song>[];
      for (final json in jsonList) {
        Uint8List? albumArt;
        final artPath = '$artDirPath/${_artFileName(json['path'])}';
        final artFile = File(artPath);
        if (await artFile.exists()) {
          albumArt = await artFile.readAsBytes();
        }

        songs.add(
          Song(
            path: json['path'],
            title: json['title'] ?? 'Unknown',
            artist: json['artist'] ?? 'Unknown Artist',
            album: json['album'],
            albumArt: albumArt,
            lyrics: json['lyrics'],
            duration: json['durationMs'] != null
                ? Duration(milliseconds: json['durationMs'])
                : null,
          ),
        );
      }

      return songs;
    } catch (e) {
      print('Error loading cache: $e');
      return [];
    }
  }

  /// Save all songs to cache
  static Future<void> saveCache(List<Song> songs) async {
    try {
      await init();
      final artDirPath = await _artDir;

      final jsonList = <Map<String, dynamic>>[];
      for (final song in songs) {
        // Save album art to file
        if (song.albumArt != null) {
          final artPath = '$artDirPath/${_artFileName(song.path)}';
          await File(artPath).writeAsBytes(song.albumArt!);
        }

        jsonList.add({
          'path': song.path,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'lyrics': song.lyrics,
          'durationMs': song.duration?.inMilliseconds,
        });
      }

      final file = File(await _cacheFilePath);
      await file.writeAsString(jsonEncode(jsonList));
      print('Saved ${songs.length} songs to cache');
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  /// Get set of cached song paths for quick lookup
  static Future<Set<String>> getCachedPaths() async {
    final songs = await loadCache();
    return songs.map((s) => s.path).toSet();
  }
}
