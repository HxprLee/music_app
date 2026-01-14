import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:metadata_god/metadata_god.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_handler.dart';
import '../services/song_cache.dart';
import '../services/platform_service.dart';
import '../services/album_art_service.dart';
import '../services/playlist_service.dart';

class AudioSignal {
  static final AudioSignal _instance = AudioSignal._internal();
  factory AudioSignal() => _instance;
  AudioSignal._internal();

  late final AudioHandler _audioHandler;
  Timer? _discordTimer;

  // Signals
  final isPlaying = signal<bool>(false);
  final currentSong = signal<Song?>(null);
  final position = signal<Duration>(Duration.zero);
  final duration = signal<Duration>(Duration.zero);
  final allSongs = listSignal<Song>([]);
  final playlists = listSignal<Playlist>([]);
  final currentPlaylist = signal<Playlist?>(null);
  final isScanning = signal<bool>(false);
  final searchQuery = signal<String>('');
  final isShuffleMode = signal<bool>(false);
  final playerExpansion = signal<double>(0.0);

  // Computed for backward compatibility or simple checks
  late final isPlayerExpanded = computed(() => playerExpansion.value > 0.1);

  // Computed
  late final searchResults = computed(() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return <Song>[];
    return allSongs.value.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          (song.album?.toLowerCase().contains(query) ?? false);
    }).toList();
  });

  late final recentlyAdded = computed(() {
    return allSongs.value.take(10).toList();
  });

  late final recentlyPlayed = computed(() {
    return allSongs.value.take(6).toList();
  });

  bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  Future<void> init(AudioHandler handler) async {
    _audioHandler = handler;
    MetadataGod.initialize();

    if (isDesktop) {
      _discordTimer = Timer.periodic(const Duration(seconds: 7), (_) {
        _updateDiscordPresence();
      });
    }

    // Listen to streams
    _audioHandler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      isShuffleMode.value = state.shuffleMode == AudioServiceShuffleMode.all;
    });

    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        duration.value = item.duration ?? Duration.zero;
        try {
          final song = allSongs.value.firstWhere((s) => s.path == item.id);
          currentSong.value = song;
        } catch (_) {}
      }
    });

    if (_audioHandler is MyAudioHandler) {
      _audioHandler.player.positionStream.listen((pos) {
        position.value = pos;
      });
    }

    // Load cache and start scan in background
    unawaited(_loadCacheAndScan());
    unawaited(_loadPlaylists());
  }

  // Discord RPC
  String? _lastDiscordSongPath;
  bool? _lastDiscordIsPlaying;

  Future<void> _updateDiscordPresence() async {
    final song = currentSong.value;
    final playing = isPlaying.value;

    if (song == null || !isDesktop) return;

    if (_lastDiscordSongPath == song.path && _lastDiscordIsPlaying == playing) {
      return;
    }

    _lastDiscordSongPath = song.path;
    _lastDiscordIsPlaying = playing;

    final artworkUrl = await AlbumArtService().getAlbumArtUrl(
      song.artist,
      song.album ?? '',
      song.title,
    );

    await PlatformService().updatePresence(
      song,
      artworkUrl: artworkUrl,
      isPlaying: playing,
    );
  }

  // Scanning & Cache
  Future<void> _loadCacheAndScan() async {
    isScanning.value = true;
    final cachedSongs = await SongCache.loadCache();
    if (cachedSongs.isNotEmpty) {
      allSongs.value = cachedSongs;
      if (_audioHandler is MyAudioHandler) {
        await _audioHandler.setPlaylist(allSongs.value);
      }
    }
    await scanMusicDirectory();
  }

  Future<void> scanMusicDirectory() async {
    isScanning.value = true;
    try {
      final musicPath = await getMusicPath();
      if (musicPath.isEmpty) {
        isScanning.value = false;
        return;
      }

      final musicDir = Directory(musicPath);
      if (!await musicDir.exists()) {
        isScanning.value = false;
        return;
      }

      final cachedPaths = allSongs.value.map((s) => s.path).toSet();
      final List<Song> newSongs = [];
      await _scanDirectory(musicDir, newSongs, cachedPaths);

      if (newSongs.isNotEmpty) {
        allSongs.addAll(newSongs);
        await SongCache.saveCache(allSongs.value);
        if (_audioHandler is MyAudioHandler) {
          await _audioHandler.setPlaylist(allSongs.value);
        }
      }
    } catch (_) {}
    isScanning.value = false;
  }

  Future<void> _scanDirectory(
    Directory dir,
    List<Song> songs,
    Set<String> cachedPaths,
  ) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          if (cachedPaths.contains(entity.path)) continue;
          if (_isSupportedAudio(entity.path)) {
            var song = Song.fromPath(entity.path);
            try {
              final metadata = await MetadataGod.readMetadata(
                file: entity.path,
              );
              bool hasArt = false;
              if (metadata.picture?.data != null) {
                try {
                  await SongCache.saveAlbumArt(
                    entity.path,
                    metadata.picture!.data,
                  );
                  hasArt = true;
                } catch (_) {}
              }
              // Calculate bitrate from file size and duration
              int? bitrate;
              if (metadata.durationMs != null && metadata.durationMs! > 0) {
                final fileSizeBytes = await entity.length();
                final durationSeconds = metadata.durationMs! / 1000;
                bitrate = ((fileSizeBytes * 8) / durationSeconds / 1000)
                    .round();
              }

              song = song.copyWith(
                title: metadata.title,
                artist: metadata.artist,
                album: metadata.album,
                hasAlbumArt: hasArt,
                duration: metadata.durationMs != null
                    ? Duration(milliseconds: metadata.durationMs!.toInt())
                    : null,
                bitrate: bitrate,
              );
            } catch (_) {}
            songs.add(song);
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, songs, cachedPaths);
        }
      }
    } catch (_) {}
  }

  // Playback Control
  Future<void> play() => _audioHandler.play();
  Future<void> pause() => _audioHandler.pause();
  Future<void> seek(Duration pos) => _audioHandler.seek(pos);
  Future<void> skipNext() => _audioHandler.skipToNext();
  Future<void> skipPrevious() => _audioHandler.skipToPrevious();

  Future<void> playSong(Song song) async {
    if (_audioHandler is MyAudioHandler) {
      final queue = _audioHandler.queue.value;
      final isInQueue = queue.any((item) => item.id == song.path);

      if (!isInQueue) {
        // Song not in current queue (playlist), switch context
        final isInLibrary = allSongs.value.any((s) => s.path == song.path);

        if (isInLibrary) {
          // Switch to All Songs
          await _audioHandler.setPlaylist(allSongs.value);
        } else {
          // Play just this song (external file)
          await _audioHandler.setPlaylist([song]);
        }
      }

      await _audioHandler.playSong(song);
    }
  }

  Future<void> playFile(File file) async {
    try {
      final song = allSongs.value.firstWhere((s) => s.path == file.path);
      await playSong(song);
    } catch (_) {
      final song = Song.fromPath(file.path);
      await playSong(song);
    }
  }

  Future<void> toggleShuffle() async {
    final currentMode = _audioHandler.playbackState.value.shuffleMode;
    final newMode = currentMode == AudioServiceShuffleMode.all
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all;
    await _audioHandler.setShuffleMode(newMode);
  }

  // Playlist Management
  Future<void> _loadPlaylists() async {
    playlists.value = await PlaylistService.loadPlaylists();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: const Uuid().v4(),
      name: name,
      songPaths: [],
      createdAt: DateTime.now(),
    );
    playlists.add(playlist);
    await PlaylistService.savePlaylists(playlists.value);
  }

  Future<void> deletePlaylist(String id) async {
    playlists.removeWhere((p) => p.id == id);
    await PlaylistService.savePlaylists(playlists.value);
  }

  Future<void> addSongToPlaylist(String playlistId, String songPath) async {
    final index = playlists.value.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = playlists[index];
      if (!playlist.songPaths.contains(songPath)) {
        final updated = playlist.copyWith(
          songPaths: [...playlist.songPaths, songPath],
        );
        playlists[index] = updated;
        await PlaylistService.savePlaylists(playlists.value);
      }
    }
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songPath,
  ) async {
    final index = playlists.value.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = playlists[index];
      final newPaths = List<String>.from(playlist.songPaths)..remove(songPath);
      playlists[index] = playlist.copyWith(songPaths: newPaths);
      await PlaylistService.savePlaylists(playlists.value);
    }
  }

  void setCurrentPlaylist(Playlist? playlist) {
    currentPlaylist.value = playlist;
  }

  Future<void> playPlaylist(Playlist playlist) async {
    final songs = playlist.songPaths
        .map(
          (path) => allSongs.value.firstWhere(
            (s) => s.path == path,
            orElse: () => Song.fromPath(path),
          ),
        )
        .toList();

    if (songs.isNotEmpty && _audioHandler is MyAudioHandler) {
      await _audioHandler.setPlaylist(songs);
      await _audioHandler.playSong(songs.first);
    }
  }

  // File Explorer Helpers
  Future<String> getMusicPath() async {
    return (await _getMusicPath()) ?? '';
  }

  Future<String?> _getMusicPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Music';
    } else {
      final home = Platform.environment['HOME'];
      if (home != null) {
        return '$home/Music';
      }
    }
    return null;
  }

  Future<List<FileSystemEntity>> fetchExplorerItems(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        final List<FileSystemEntity> items = [];
        await for (final entity in dir.list()) {
          if (entity is Directory) {
            if (await _hasMusic(entity)) items.add(entity);
          } else if (entity is File) {
            if (_isSupportedAudio(entity.path)) items.add(entity);
          }
        }
        items.sort((a, b) {
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
        return items;
      }
    } catch (_) {}
    return [];
  }

  bool _isSupportedAudio(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp3') ||
        p.endsWith('.m4a') ||
        p.endsWith('.wav') ||
        p.endsWith('.flac') ||
        p.endsWith('.ogg');
  }

  Future<bool> _hasMusic(Directory dir) async {
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && _isSupportedAudio(entity.path)) return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> addFolderToPlaylist(String playlistId, String folderPath) async {
    final dir = Directory(folderPath);
    if (await dir.exists()) {
      final List<String> songsToAdd = [];
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && _isSupportedAudio(entity.path)) {
            songsToAdd.add(entity.path);
          }
        }
      } catch (_) {}

      if (songsToAdd.isNotEmpty) {
        final index = playlists.value.indexWhere((p) => p.id == playlistId);
        if (index != -1) {
          final playlist = playlists[index];
          final newPaths = List<String>.from(playlist.songPaths);
          for (final path in songsToAdd) {
            if (!newPaths.contains(path)) {
              newPaths.add(path);
            }
          }
          playlists[index] = playlist.copyWith(songPaths: newPaths);
          await PlaylistService.savePlaylists(playlists.value);
        }
      }
    }
  }

  Future<Song> getExplorerSong(File file) async {
    try {
      return allSongs.value.firstWhere((s) => s.path == file.path);
    } catch (_) {
      var song = Song.fromPath(file.path);
      try {
        final metadata = await MetadataGod.readMetadata(file: file.path);
        song = song.copyWith(
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          duration: metadata.durationMs != null
              ? Duration(milliseconds: metadata.durationMs!.toInt())
              : null,
        );
      } catch (_) {}
      return song;
    }
  }

  void dispose() {
    _discordTimer?.cancel();
  }
}

final audioSignal = AudioSignal();
