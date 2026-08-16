// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:dart_discord_presence/dart_discord_presence.dart';
import 'platform_service_stub.dart'
    if (dart.library.io) 'platform_service_desktop.dart';

abstract class PlatformService {
  static final PlatformService _instance = getPlatformService();
  factory PlatformService() => _instance;

  Future<void> init();
  Future<void> updatePresence(
    dynamic song, {
    String? artworkUrl,
    bool isPlaying = true,
    int? startTimeStamp,
    int? endTimeStamp,
    List<DiscordButton>? buttons,
  });
  Future<void> clearPresence();
  Future<void> dispose();
}
