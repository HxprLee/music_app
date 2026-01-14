import 'dart:async';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import '../models/song.dart';

class DiscordRpcService {
  static final DiscordRpcService _instance = DiscordRpcService._internal();
  factory DiscordRpcService() => _instance;
  DiscordRpcService._internal();

  bool _isConnected = false;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  static const String _applicationId = '1453422309057757307';

  String _truncate(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  String _sanitize(String? text) {
    if (text == null) return '';
    // Basic sanitization, but flutter_discord_rpc should handle UTF-8
    return text
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('…', '...')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control characters
        .trim();
  }

  Future<void> init() async {
    if (_isConnected) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    try {
      if (!_isInitialized) {
        print('DiscordRpcService: Initializing with ID $_applicationId');
        FlutterDiscordRPC.initialize(_applicationId);
        _isInitialized = true;
      }
      await FlutterDiscordRPC.instance.connect();
      _isConnected = true;
      print('DiscordRpcService: Connected.');
    } catch (e) {
      print('DiscordRpcService: Init error: $e');
      _isConnected = false;
    } finally {
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter?.complete();
      }
      _initCompleter = null;
    }
  }

  Future<void> updatePresence(
    Song song, {
    String? artworkUrl,
    bool isPlaying = true,
  }) async {
    try {
      if (!_isConnected) {
        await init();
      }

      if (!_isConnected) return;

      print(
        'DiscordRpcService: updatePresence called for "${song.title}" (playing: $isPlaying)',
      );

      final activity = RPCActivity(
        activityType: ActivityType.listening,
        details: _truncate(_sanitize(song.title), 128),
        state: _truncate(_sanitize(song.artist), 128),
        timestamps: isPlaying
            ? RPCTimestamps(start: DateTime.now().millisecondsSinceEpoch)
            : null,
        assets: RPCAssets(
          largeImage: artworkUrl ?? 'app_icon',
          largeText: isPlaying ? '▸ Playing' : '⏸︎ Paused',
        ),
      );

      print('DiscordRpcService: Sending activity (playing: $isPlaying)');
      print(
        'DiscordRpcService: Details: ${activity.details}, State: ${activity.state}',
      );
      await FlutterDiscordRPC.instance.setActivity(activity: activity);
      print('DiscordRpcService: setActivity sent successfully.');
    } catch (e, stack) {
      print('DiscordRpcService: updatePresence error: $e');
      print('Stack trace: $stack');
      _isConnected = false;
    }
  }

  Future<void> clearPresence() async {
    if (!_isConnected) return;

    try {
      print('DiscordRpcService: Clearing presence...');
      await FlutterDiscordRPC.instance.clearActivity();
    } catch (e) {
      print('DiscordRpcService: clearPresence error: $e');
      _isConnected = false;
    }
  }

  Future<void> dispose() async {
    print('DiscordRpcService: Disposing and disconnecting...');
    try {
      await FlutterDiscordRPC.instance.disconnect();
    } catch (e) {
      // Ignore errors during disconnect
    }
    _isConnected = false;
  }
}
