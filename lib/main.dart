import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'providers/audio_provider.dart';
import 'screens/home_screen.dart';

import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';

import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

late AudioHandler _audioHandler;

Future<void> main() async {
  // Ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Explicitly register JustAudioMediaKit
  JustAudioPlatform.instance = JustAudioMediaKit();
  JustAudioMediaKit.ensureInitialized();

  // Initialize transparent window
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.transparent,
    color: const Color.fromARGB(165, 18, 22, 26),
  );

  // Initialize AudioService
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_app.channel.audio',
      androidNotificationChannelName: 'Music Playback',
    ),
  );

  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioProvider(_audioHandler),
      child: MaterialApp(
        title: 'Music App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFCE7AC),
            brightness: Brightness.dark,
            secondary: const Color(0xFFFCE7AC),
          ),
          useMaterial3: true,
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Iosevka Nerd Font',
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
