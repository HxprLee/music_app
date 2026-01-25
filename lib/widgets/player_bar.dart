import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signals/signals_flutter.dart';
import '../signals/audio_signal.dart';
import '../services/album_art_cache.dart';
import '../screens/now_playing_screen.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar>
    with SingleTickerProviderStateMixin {
  bool _showPlayPauseIcon = false;
  File? _currentAlbumArt;
  String? _currentSongPath;

  void _togglePlayPauseIcon() {
    setState(() {
      _showPlayPauseIcon = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final isMobile = !isDesktop;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isCompact = isMobile || availableWidth < 700;

        return Watch((context) {
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

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: isCompact
                ? _buildCompactPlayer(
                    key: const ValueKey('compact'),
                    currentSong: currentSong,
                    isPlaying: isPlaying,
                    progress: progress,
                    isMobile: isMobile,
                  )
                : _buildFullPlayer(
                    key: const ValueKey('full'),
                    currentSong: currentSong,
                    isPlaying: isPlaying,
                    progress: progress,
                  ),
          );
        });
      },
    );
  }

  Widget _buildAlbumArtWithProgress({
    required dynamic currentSong,
    required double progress,
    required bool isPlaying,
    bool showPlayPauseOnTap = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: const Color.fromARGB(51, 255, 239, 175),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(204, 255, 239, 175),
              ),
            ),
          ),
          Hero(
            tag: 'player-artwork',
            child: ClipOval(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 42,
                height: 42,
                color: Colors.grey[800],
                child: _currentAlbumArt != null
                    ? Image(
                        image: ResizeImage(
                          FileImage(_currentAlbumArt!),
                          width: 100, // Optimize memory: decode at smaller size
                        ),
                        fit: BoxFit.cover,
                      )
                    : (showPlayPauseOnTap && _showPlayPauseIcon)
                    ? FaIcon(
                        isPlaying
                            ? FontAwesomeIcons.pause
                            : FontAwesomeIcons.play,
                        color: const Color(0xFFFCE7AC),
                        size: 16,
                      )
                    : const FaIcon(
                        FontAwesomeIcons.music,
                        color: Colors.white54,
                        size: 16,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongInfo({
    required dynamic currentSong,
    bool showAlbum = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currentSong?.title ?? 'No song playing',
          style: const TextStyle(
            color: Color(0xFFFCE7AC),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          showAlbum && currentSong?.album != null
              ? '${currentSong?.artist} • ${currentSong?.album}'
              : currentSong?.artist ?? '',
          style: const TextStyle(
            color: Color.fromARGB(204, 252, 231, 172),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCompactPlayer({
    Key? key,
    required currentSong,
    required bool isPlaying,
    required double progress,
    bool isMobile = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
        );
      },
      child: Container(
        key: key,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 80,
            margin: EdgeInsets.fromLTRB(isMobile ? 12 : 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(170, 17, 23, 28),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color.fromARGB(38, 255, 239, 175),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Album Art with Circular Progress - Acts as Play/Pause button
                _buildAlbumArtWithProgress(
                  currentSong: currentSong,
                  progress: progress,
                  isPlaying: isPlaying,
                  showPlayPauseOnTap: true,
                  onTap: () {
                    _togglePlayPauseIcon();
                    if (isPlaying) {
                      audioSignal.pause();
                    } else {
                      audioSignal.play();
                    }
                  },
                ),
                const SizedBox(width: 14),
                // Song Info
                Expanded(child: _buildSongInfo(currentSong: currentSong)),
                const SizedBox(width: 14),
                // Compact Controls
                if (!isMobile) ...{
                  _buildControlButton(
                    icon: FontAwesomeIcons.ellipsisVertical,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                },
                _buildControlButton(
                  icon: FontAwesomeIcons.backwardStep,
                  onPressed: audioSignal.skipPrevious,
                ),
                const SizedBox(width: 10),
                _buildControlButton(
                  icon: FontAwesomeIcons.forwardStep,
                  onPressed: audioSignal.skipNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullPlayer({
    Key? key,
    required currentSong,
    required bool isPlaying,
    required double progress,
  }) {
    return Container(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 80,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(170, 17, 23, 28),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color.fromARGB(38, 255, 239, 175),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Left Controls (Prev, Play/Pause, Next)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: FontAwesomeIcons.backwardStep,
                      onPressed: audioSignal.skipPrevious,
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: isPlaying
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.play,
                      onPressed: () {
                        if (isPlaying) {
                          audioSignal.pause();
                        } else {
                          audioSignal.play();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.forwardStep,
                      onPressed: audioSignal.skipNext,
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Center Info (Circular Progress + Art, Title, Artist)
                Expanded(
                  child: Row(
                    children: [
                      _buildAlbumArtWithProgress(
                        currentSong: currentSong,
                        progress: progress,
                        isPlaying: isPlaying,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSongInfo(
                          currentSong: currentSong,
                          showAlbum: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: FontAwesomeIcons.ellipsisVertical,
                      size: 22,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.listOl,
                      size: 22,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.repeat,
                      size: 22,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.shuffle,
                      size: 22,
                      color: audioSignal.isShuffleMode.value
                          ? const Color(0xFFFCE7AC)
                          : const Color.fromARGB(100, 252, 231, 172),
                      onPressed: audioSignal.toggleShuffle,
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.volumeHigh,
                      size: 22,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 24,
    Color? color,
  }) {
    return IconButton(
      icon: FaIcon(icon, color: color ?? const Color(0xFFFCE7AC), size: size),
      onPressed: onPressed,
    );
  }
}
