import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'router.dart';

import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';
import 'services/platform_service.dart';

import 'signals/audio_signal.dart';
import 'signals/settings_signal.dart';

late AudioHandler _audioHandler;

bool get isDesktop =>
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

Future<void> main() async {
  print('APP_START: Starting main()');
  // Ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  print('APP_START: Widgets initialized');

  // Initialize platform-specific features (Desktop only)
  await PlatformService().init();

  print('APP_START: Initializing AudioService');
  // Initialize AudioService
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_app.channel.audio',
      androidNotificationChannelName: 'Music Playback',
    ),
  );
  print('APP_START: AudioService initialized');

  // Initialize Signals
  await settingsSignal.loadSettings();
  await audioSignal.init(_audioHandler);

  print('APP_START: Running app');
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      // Access signal value here to register dependency
      final textScale = settingsSignal.textScaleFactor.value;

      return MaterialApp.router(
        title: 'Music App',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: isDesktop
              ? const Color.fromARGB(0, 0, 0, 0)
              : null,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFCE7AC),
            brightness: Brightness.dark,
            secondary: const Color(0xFFFCE7AC),
          ),
          useMaterial3: true,
          textTheme: isDesktop
              ? ThemeData.dark().textTheme.apply(
                  fontFamily: 'Iosevka Nerd Font',
                )
              : null,
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
      );
    });
  }
}
