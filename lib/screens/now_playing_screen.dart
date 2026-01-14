import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signals/signals_flutter.dart';
import '../signals/audio_signal.dart';
import '../services/album_art_cache.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  File? _currentAlbumArt;
  String? _currentSongPath;

  void _loadAlbumArt(String? songPath) async {
    if (songPath == null || songPath == _currentSongPath) return;
    _currentSongPath = songPath;

    final art = await AlbumArtCache().getArt(songPath);
    if (mounted && songPath == _currentSongPath) {
      setState(() {
        _currentAlbumArt = art;
      });
    }
  }

  bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${minutes}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Watch((context) {
        final currentSong = audioSignal.currentSong.value;
        final isPlaying = audioSignal.isPlaying.value;
        final position = audioSignal.position.value;
        final duration = audioSignal.duration.value;

        // Load album art when song changes
        if (currentSong != null) {
          _loadAlbumArt(currentSong.path);
        }

        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }

        return Stack(
          children: [
            // Blurred background
            if (_currentAlbumArt != null)
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Image.file(_currentAlbumArt!, fit: BoxFit.cover),
                ),
              ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0D1117).withOpacity(0.3),
                      const Color(0xFF0D1117).withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'Now Playing',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Album artwork
                  Hero(
                    tag: 'player-artwork',
                    child: Container(
                      width: isMobile ? 300 : 400,
                      height: isMobile ? 300 : 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _currentAlbumArt != null
                            ? Image.file(_currentAlbumArt!, fit: BoxFit.cover)
                            : Container(
                                color: const Color(0xFF1E222B),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 80,
                                  color: Colors.white24,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Song info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        Text(
                          currentSong?.title ?? 'No song playing',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong?.artist ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (currentSong?.album != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            currentSong!.album!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Seekbar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: const Color(0xFFFCE7AC),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: const Color(0xFFFCE7AC),
                            overlayColor: const Color(
                              0xFFFCE7AC,
                            ).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (value) {
                              final newPosition = Duration(
                                milliseconds: (value * duration.inMilliseconds)
                                    .round(),
                              );
                              audioSignal.seek(newPosition);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.shuffle,
                          color: audioSignal.isShuffleMode.value
                              ? const Color(0xFFFCE7AC)
                              : Colors.white54,
                          size: 20,
                        ),
                        onPressed: () => audioSignal.toggleShuffle(),
                      ),
                      const SizedBox(width: 20),
                      // Previous
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.backward,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => audioSignal.skipPrevious(),
                      ),
                      const SizedBox(width: 20),
                      // Play/Pause
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE7AC),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFCE7AC).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: FaIcon(
                            isPlaying
                                ? FontAwesomeIcons.pause
                                : FontAwesomeIcons.play,
                            color: const Color(0xFF0D1117),
                            size: 24,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              audioSignal.pause();
                            } else {
                              audioSignal.play();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Next
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.forward,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => audioSignal.skipNext(),
                      ),
                      const SizedBox(width: 20),
                      // Repeat
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.repeat,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Implement repeat mode
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
