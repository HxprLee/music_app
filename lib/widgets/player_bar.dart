import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../services/album_art_cache.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar>
    with SingleTickerProviderStateMixin {
  bool _showPlayPauseIcon = false;
  Uint8List? _currentAlbumArt;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isCompact = availableWidth < 650;

        return Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            final currentSong = audioProvider.currentSong;
            final isPlaying = audioProvider.isPlaying;
            final position = audioProvider.position;
            final duration = audioProvider.duration;

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
                      audioProvider: audioProvider,
                    )
                  : _buildFullPlayer(
                      key: const ValueKey('full'),
                      currentSong: currentSong,
                      isPlaying: isPlaying,
                      progress: progress,
                      audioProvider: audioProvider,
                    ),
            );
          },
        );
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
          ClipOval(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42,
              height: 42,
              color: Colors.grey[800],
              child: _currentAlbumArt != null
                  ? Image.memory(_currentAlbumArt!, fit: BoxFit.cover)
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
    required AudioProvider audioProvider,
  }) {
    return Container(
      key: key,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 80,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                    audioProvider.pause();
                  } else {
                    audioProvider.play();
                  }
                },
              ),
              const SizedBox(width: 14),
              // Song Info
              Expanded(child: _buildSongInfo(currentSong: currentSong)),
              const SizedBox(width: 14),
              // Compact Controls
              _buildControlButton(
                icon: FontAwesomeIcons.ellipsisVertical,
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              _buildControlButton(
                icon: FontAwesomeIcons.backwardStep,
                onPressed: audioProvider.skipPrevious,
              ),
              const SizedBox(width: 10),
              _buildControlButton(
                icon: FontAwesomeIcons.forwardStep,
                onPressed: audioProvider.skipNext,
              ),
            ],
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
    required AudioProvider audioProvider,
  }) {
    return Container(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
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
                      onPressed: audioProvider.skipPrevious,
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: isPlaying
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.play,
                      onPressed: () {
                        if (isPlaying) {
                          audioProvider.pause();
                        } else {
                          audioProvider.play();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      icon: FontAwesomeIcons.forwardStep,
                      onPressed: audioProvider.skipNext,
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Center Info (Circular Progress + Art, Title, Artist)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      onPressed: () {},
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
  }) {
    return IconButton(
      icon: FaIcon(icon, color: const Color(0xFFFCE7AC), size: size),
      onPressed: onPressed,
    );
  }
}
