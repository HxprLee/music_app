import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'platform_service.dart';
import 'discord_rpc_service.dart';

PlatformService getPlatformService() => PlatformServiceDesktop();

class PlatformServiceDesktop implements PlatformService {
  @override
  Future<void> init() async {
    if (kIsWeb) return;
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Explicitly register JustAudioMediaKit on Desktop
      JustAudioPlatform.instance = JustAudioMediaKit();
      JustAudioMediaKit.ensureInitialized();

      // Initialize transparent window on Desktop
      await Window.initialize();
      await Window.setEffect(
        effect: WindowEffect.transparent,
        color: const Color.fromARGB(165, 18, 22, 26),
      );

      // Initialize Discord RPC
      await DiscordRpcService().init();
    }
  }

  @override
  Future<void> updatePresence(dynamic song, {String? artworkUrl, bool isPlaying = true}) async {
    await DiscordRpcService().updatePresence(
      song,
      artworkUrl: artworkUrl,
      isPlaying: isPlaying,
    );
  }

  @override
  Future<void> clearPresence() async {
    await DiscordRpcService().clearPresence();
  }

  @override
  Future<void> dispose() async {
    await DiscordRpcService().dispose();
  }
}
