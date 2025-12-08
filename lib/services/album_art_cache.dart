import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';

/// LRU cache for album art - keeps only a limited number in memory
/// and loads from disk on-demand
class AlbumArtCache {
  static final AlbumArtCache _instance = AlbumArtCache._internal();
  factory AlbumArtCache() => _instance;
  AlbumArtCache._internal();

  // LRU cache with max 20 entries (~20MB max)
  static const int _maxCacheSize = 20;
  final LinkedHashMap<String, Uint8List> _memoryCache = LinkedHashMap();

  // Pending loads to avoid duplicate requests
  final Map<String, Future<Uint8List?>> _pendingLoads = {};

  // Directory paths
  String? _artDirPath;

  /// Initialize the cache directory
  Future<void> init() async {
    if (_artDirPath != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _artDirPath = '${dir.path}/music_app_cache/album_art';
    final artDir = Directory(_artDirPath!);
    if (!await artDir.exists()) {
      await artDir.create(recursive: true);
    }
  }

  /// Get the file path for a song's album art
  String _getArtPath(String songPath) {
    final hash = songPath.hashCode.abs();
    return '$_artDirPath/$hash.jpg';
  }

  /// Check if album art exists on disk for a song
  Future<bool> hasArt(String songPath) async {
    await init();
    final file = File(_getArtPath(songPath));
    return file.exists();
  }

  /// Get album art for a song (from memory cache, disk, or extract)
  Future<Uint8List?> getArt(String songPath) async {
    await init();

    // Check memory cache first
    if (_memoryCache.containsKey(songPath)) {
      // Move to end (most recently used)
      final art = _memoryCache.remove(songPath)!;
      _memoryCache[songPath] = art;
      return art;
    }

    // Check if already loading
    if (_pendingLoads.containsKey(songPath)) {
      return _pendingLoads[songPath];
    }

    // Start loading
    final loadFuture = _loadArt(songPath);
    _pendingLoads[songPath] = loadFuture;

    try {
      final art = await loadFuture;
      if (art != null) {
        _addToCache(songPath, art);
      }
      return art;
    } finally {
      _pendingLoads.remove(songPath);
    }
  }

  /// Load art from disk or extract from audio file
  Future<Uint8List?> _loadArt(String songPath) async {
    final artPath = _getArtPath(songPath);
    final artFile = File(artPath);

    // Try loading from disk cache
    if (await artFile.exists()) {
      try {
        return await artFile.readAsBytes();
      } catch (e) {
        debugPrint('Error reading art from disk: $e');
      }
    }

    // Fall back to extracting from audio file
    try {
      final metadata = await MetadataGod.readMetadata(file: songPath);
      if (metadata.picture?.data != null) {
        final art = metadata.picture!.data;
        // Cache to disk for future use
        await _saveArtToDisk(songPath, art);
        return art;
      }
    } catch (e) {
      debugPrint('Error extracting art from $songPath: $e');
    }

    return null;
  }

  /// Save album art to disk cache
  Future<void> _saveArtToDisk(String songPath, Uint8List art) async {
    try {
      final artPath = _getArtPath(songPath);
      await File(artPath).writeAsBytes(art);
    } catch (e) {
      debugPrint('Error saving art to disk: $e');
    }
  }

  /// Add art to memory cache with LRU eviction
  void _addToCache(String songPath, Uint8List art) {
    // Remove oldest entries if cache is full
    while (_memoryCache.length >= _maxCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[songPath] = art;
  }

  /// Get art file URI for MPRIS (returns file path, not bytes)
  Future<Uri?> getArtUri(String songPath) async {
    await init();
    final artPath = _getArtPath(songPath);
    final artFile = File(artPath);

    // Check if already cached on disk
    if (await artFile.exists()) {
      return artFile.uri;
    }

    // Try to extract and cache
    try {
      final metadata = await MetadataGod.readMetadata(file: songPath);
      if (metadata.picture?.data != null) {
        await _saveArtToDisk(songPath, metadata.picture!.data);
        return artFile.uri;
      }
    } catch (e) {
      debugPrint('Error getting art URI for $songPath: $e');
    }

    return null;
  }

  /// Clear memory cache (disk cache remains)
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Preload art for a list of songs (e.g., visible songs)
  Future<void> preloadArt(List<String> songPaths) async {
    for (final path in songPaths.take(10)) {
      // Preload up to 10
      if (!_memoryCache.containsKey(path)) {
        getArt(path); // Fire and forget
      }
    }
  }
}
