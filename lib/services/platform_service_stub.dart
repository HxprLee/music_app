// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:dart_discord_presence/dart_discord_presence.dart';
import 'platform_service.dart';

PlatformService getPlatformService() => PlatformServiceStub();

class PlatformServiceStub implements PlatformService {
  @override
  Future<void> init() async {
    // No-op on mobile/web
  }

  @override
  Future<void> updatePresence(
    dynamic song, {
    String? artworkUrl,
    bool isPlaying = true,
    int? startTimeStamp,
    int? endTimeStamp,
    List<DiscordButton>? buttons,
  }) async {
    // No-op on mobile/web
  }

  @override
  Future<void> clearPresence() async {
    // No-op on mobile/web
  }

  @override
  Future<void> dispose() async {
    // No-op on mobile/web
  }
}
