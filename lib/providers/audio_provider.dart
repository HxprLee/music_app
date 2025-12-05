import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';
import '../services/audio_handler.dart';

import 'package:metadata_god/metadata_god.dart';

import '../services/song_cache.dart';

class AudioProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;

  List<Song> _allSongs = [];
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isScanning = false;

  // Getters
  List<Song> get allSongs => _allSongs;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isScanning => _isScanning;
  List<Song> get recentlyAdded => _allSongs.take(10).toList();
  List<Song> get recentlyPlayed => _allSongs.take(6).toList(); // Placeholder

  AudioProvider(this._audioHandler) {
    _init();
  }

  void _init() {
    // Initialize MetadataGod
    MetadataGod.initialize();

    // Listen to playback state
    _audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      _position = state.position;
      notifyListeners();
    });

    // Listen to media item changes
    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        _duration = item.duration ?? Duration.zero;

        // Find song by path/id
        try {
          final song = _allSongs.firstWhere((s) => s.path == item.id);
          _currentSong = song;
        } catch (_) {
          // Song might not be in the list
        }
        notifyListeners();
      }
    });

    // Load cache first, then scan for new files
    _loadCacheAndScan();

    // Listen to position stream directly for smooth progress
    if (_audioHandler is MyAudioHandler) {
      _audioHandler.player.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });
    }
  }

  Future<void> _loadCacheAndScan() async {
    _isScanning = true;
    notifyListeners();

    // Load cached songs first
    final cachedSongs = await SongCache.loadCache();
    if (cachedSongs.isNotEmpty) {
      _allSongs = cachedSongs;
      print('Loaded ${_allSongs.length} songs from cache');
      notifyListeners();

      // Update handler playlist
      if (_audioHandler is MyAudioHandler) {
        await _audioHandler.setPlaylist(_allSongs);
      }
    }

    // Now scan for new files
    await scanMusicDirectory();
  }

  Future<void> scanMusicDirectory() async {
    _isScanning = true;
    notifyListeners();

    try {
      final home = Platform.environment['HOME'];
      if (home == null) {
        print('Could not find HOME directory');
        _isScanning = false;
        notifyListeners();
        return;
      }

      final musicDir = Directory('$home/Music');
      if (!await musicDir.exists()) {
        print('Music directory does not exist: ${musicDir.path}');
        _isScanning = false;
        notifyListeners();
        return;
      }

      // Get cached paths to avoid re-scanning known files
      final cachedPaths = _allSongs.map((s) => s.path).toSet();
      final List<Song> newSongs = [];
      await _scanDirectory(musicDir, newSongs, cachedPaths);

      if (newSongs.isNotEmpty) {
        _allSongs.addAll(newSongs);
        print('Found ${newSongs.length} new songs');

        // Save updated cache
        await SongCache.saveCache(_allSongs);

        // Update handler playlist
        if (_audioHandler is MyAudioHandler) {
          await _audioHandler.setPlaylist(_allSongs);
        }
      }

      print('Total: ${_allSongs.length} songs');
    } catch (e) {
      print('Error scanning music directory: $e');
    }

    _isScanning = false;
    notifyListeners();
  }

  Future<void> _scanDirectory(
    Directory dir,
    List<Song> songs,
    Set<String> cachedPaths,
  ) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          // Skip already cached files
          if (cachedPaths.contains(entity.path)) {
            continue;
          }

          final path = entity.path.toLowerCase();
          if (path.endsWith('.mp3') ||
              path.endsWith('.m4a') ||
              path.endsWith('.wav') ||
              path.endsWith('.flac') ||
              path.endsWith('.ogg')) {
            var song = Song.fromPath(entity.path);

            try {
              final metadata = await MetadataGod.readMetadata(
                file: entity.path,
              );
              song = song.copyWith(
                title: metadata.title,
                artist: metadata.artist,
                album: metadata.album,
                albumArt: metadata.picture?.data,
                duration: metadata.durationMs != null
                    ? Duration(milliseconds: metadata.durationMs!.toInt())
                    : null,
              );
            } catch (e) {
              print('Error reading metadata for ${entity.path}: $e');
            }

            songs.add(song);
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, songs, cachedPaths);
        }
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
    }
  }

  Future<void> playSong(Song song) async {
    try {
      if (_audioHandler is MyAudioHandler) {
        await _audioHandler.playSong(song);
      } else {
        // Fallback or generic play
        // For generic handler, we might need to add to queue and play
      }
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  Future<void> play() async {
    await _audioHandler.play();
  }

  Future<void> pause() async {
    await _audioHandler.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> skipNext() async {
    await _audioHandler.skipToNext();
  }

  Future<void> skipPrevious() async {
    await _audioHandler.skipToPrevious();
  }
}
