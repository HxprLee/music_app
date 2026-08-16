// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/queue_model.dart';

/// File-backed persistence for [QueueModel]. Writes to a single
/// `queue.json` file in the app documents directory. Emits the new model
/// on its broadcast stream after every mutation so subscribers can mirror
/// the canonical state into their own signals.
class QueueService {
  static const String _fileName = 'queue.json';
  static const String _ytCacheFileName = 'yt_songs_cache.json';

  static final QueueService _instance = QueueService._internal();
  factory QueueService() => _instance;
  QueueService._internal();

  QueueModel _model = const QueueModel();
  QueueModel get model => _model;

  /// Cached YouTube song metadata (videoId → Song JSON). Persisted to
  /// [ytSongsCache] so YouTube queue entries resolve without re-fetching.
  Map<String, String> _ytSongsCache = {};

  final _controller = StreamController<QueueModel>.broadcast();
  Stream<QueueModel> get stream => _controller.stream;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/ecilaes_cache';
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('$path/$_fileName');
  }

  Future<File> get _ytCacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/ecilaes_cache';
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('$path/$_ytCacheFileName');
  }

  Future<void> load() async {
    try {
      final f = await _file;
      if (await f.exists()) {
        final content = await f.readAsString();
        _model = QueueModel.decode(content);
        _controller.add(_model);
      }
    } catch (_) {}

    try {
      final f = await _ytCacheFile;
      if (await f.exists()) {
        final content = await f.readAsString();
        _ytSongsCache = Map<String, String>.from(
          jsonDecode(content) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final f = await _file;
      await f.writeAsString(QueueModel.encode(_model));
    } catch (_) {}
  }

  Future<void> _saveYtCache() async {
    try {
      final f = await _ytCacheFile;
      await f.writeAsString(jsonEncode(_ytSongsCache));
    } catch (_) {}
  }

  void _emit() {
    _controller.add(_model);
  }

  /// Replace the entire model. Used by [QueueSignal] after a single
  /// authoritative update so that persistence and the broadcast stream
  /// stay aligned with the signal layer.
  void replace(QueueModel model) {
    _model = model;
    _emit();
    unawaited(_save());
  }

  /// Returns the cached JSON for a YouTube song, or null if not cached.
  String? getYtSongJson(String path) => _ytSongsCache[path];

  /// Caches a YouTube song's JSON so it resolves on restart without re-fetching.
  void cacheYtSong(String path, String songJson) {
    if (_ytSongsCache[path] != songJson) {
      _ytSongsCache[path] = songJson;
      unawaited(_saveYtCache());
    }
  }

  /// Returns all cached YouTube song JSON values.
  Iterable<String> getAllCachedYtSongs() => _ytSongsCache.values;

  String? getRadioSeed() => _model.radioSeed;
  List<String> getRecentRadioSeeds() => List<String>.from(_model.recentRadioSeeds);

  void dispose() {
    _controller.close();
  }
}
