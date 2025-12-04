import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  bool _showPlayPauseIcon = false;

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 800;

    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;
        final isPlaying = audioProvider.isPlaying;
        final position = audioProvider.position;
        final duration = audioProvider.duration;

        // Calculate progress for circular indicator
        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }

        if (isCompact) {
          return _buildCompactPlayer(
            currentSong: currentSong,
            isPlaying: isPlaying,
            progress: progress,
            audioProvider: audioProvider,
          );
        }

        return _buildFullPlayer(
          currentSong: currentSong,
          isPlaying: isPlaying,
          progress: progress,
          audioProvider: audioProvider,
        );
      },
    );
  }

  Widget _buildCompactPlayer({
    required currentSong,
    required bool isPlaying,
    required double progress,
    required AudioProvider audioProvider,
  }) {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(153, 17, 23, 28),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color.fromARGB(38, 252, 231, 172),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Album Art with Circular Progress - Acts as Play/Pause button
          InkWell(
            onTap: () {
              _togglePlayPauseIcon();
              if (isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.play();
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
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
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[800],
                    child: currentSong?.albumArt != null
                        ? Image.memory(
                            currentSong!.albumArt!,
                            fit: BoxFit.cover,
                          )
                        : _showPlayPauseIcon
                        ? Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFFFCE7AC),
                            size: 20,
                          )
                        : const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Song Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  currentSong?.title ?? 'No song playing',
                  style: const TextStyle(
                    color: Color(0xFFFCE7AC),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentSong?.artist ?? '',
                  style: const TextStyle(
                    color: Color(0xFFFCE7AC),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Compact Controls
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFCE7AC)),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.skip_next,
              color: Color(0xFFFCE7AC),
              size: 28,
            ),
            onPressed: audioProvider.skipNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer({
    required currentSong,
    required bool isPlaying,
    required double progress,
    required AudioProvider audioProvider,
  }) {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(153, 17, 23, 28),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color.fromARGB(38, 252, 231, 172),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Left Controls (Prev, Play/Pause, Next)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Color(0xFFFCE7AC),
                  size: 36,
                ),
                onPressed: audioProvider.skipPrevious,
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: const Color(0xFFFCE7AC),
                  size: 36,
                ),
                onPressed: () {
                  if (isPlaying) {
                    audioProvider.pause();
                  } else {
                    audioProvider.play();
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Color(0xFFFCE7AC),
                  size: 36,
                ),
                onPressed: audioProvider.skipNext,
              ),
            ],
          ),

          const Spacer(),

          // Center Info (Circular Progress + Art, Title, Artist)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Album Art with Circular Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
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
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[800],
                      child: currentSong?.albumArt != null
                          ? Image.memory(
                              currentSong!.albumArt!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong?.title ?? 'No song playing',
                    style: const TextStyle(
                      color: Color(0xFFFCE7AC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong?.album != null
                        ? '${currentSong?.artist} • ${currentSong?.album}'
                        : currentSong?.artist ?? '',
                    style: const TextStyle(
                      color: Color(0xFFFCE7AC),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Right Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFFFCE7AC)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Color(0xFFFCE7AC)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.repeat, color: Color(0xFFFCE7AC)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.shuffle, color: Color(0xFFFCE7AC)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFFFCE7AC)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
