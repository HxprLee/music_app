import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'providers/audio_provider.dart';
import 'screens/home_screen.dart';

import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';

late AudioHandler _audioHandler;

Future<void> main() async {
  // Ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize transparent window
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.transparent,
    color: Colors.transparent,
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
          scaffoldBackgroundColor: const Color.fromARGB(179, 18, 22, 26),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFCE7AC),
            brightness: Brightness.dark,
            secondary: const Color(0xFFFCE7AC),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
