import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/widgets/marquee_text.dart';
import 'package:signals/signals_flutter.dart';
import '../signals/audio_signal.dart';
import '../services/album_art_cache.dart';
import '../models/song.dart';

class MorphingPlayer extends StatefulWidget {
  final double bottomOffset;
  final double leftOffset;

  const MorphingPlayer({super.key, this.bottomOffset = 0, this.leftOffset = 0});

  @override
  State<MorphingPlayer> createState() => _MorphingPlayerState();
}

class _MorphingPlayerState extends State<MorphingPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  File? _currentAlbumArt;
  String? _currentSongPath;

  // Layout Configuration
  // Using getters to allow dynamic updates if needed, though mostly constant
  double get _barHeight => 80.0;
  double get _miniArtSize => 50.0;
  double get _fullArtSize => 650.0;

  // Compact Layout Specs
  double get _compactMargin => 6.0;
  double get _compactPadding => 16.0;

  // Full Layout Specs
  double get _fullMargin => 24.0;
  double get _fullPadding => 20.0; // Reduced from 20.0
  double get _leftControlsWidth => 160.0; // Reduced slightly for tighter look
  double get _artSpacing => -12.0; // Comfortable spacing

  double get _startTop => (_barHeight / 2) - 21;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
        )..addListener(() {
          // Update signal for global UI coordination (like hiding navbar)
          audioSignal.playerExpansion.value = _controller.value;
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _handleDragUpdate(DragUpdateDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    _controller.value -= details.primaryDelta! / screenHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value >= 0.5 || details.primaryVelocity! < -500) {
      _controller.animateTo(1.0, curve: Curves.fastLinearToSlowEaseIn);
    } else {
      _controller.animateTo(0.0, curve: Curves.fastLinearToSlowEaseIn);
    }
  }

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

  // Helper to calculate text height dynamically

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Watch((context) {
      final currentSong = audioSignal.currentSong.value;
      final isPlaying = audioSignal.isPlaying.value;
      final duration = audioSignal.duration.value;

      if (currentSong != null) {
        _loadAlbumArt(currentSong.path);
      }

      // Calculate where the scrollable content should start
      // artTop + fullArtSize + spacing (24) + textHeight (60) + spacing (24)
      final fullArtSize = isMobile ? screenWidth - 64.0 : 560.0;
      final contentTopStart = 100.0 + fullArtSize + 24.0 + 58.0;

      // Dynamic Layout Values based on Config
      final isCompact = isMobile;
      final margin = isCompact ? _compactMargin : _fullMargin;
      final startArtLeft = isCompact
          ? _compactPadding
          : _fullPadding + _leftControlsWidth + _artSpacing;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          final topPadding = MediaQuery.of(context).padding.top;
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final currentTopPadding = lerpDouble(0, topPadding, value)!;
          final currentBottomPadding = lerpDouble(0, bottomPadding, value)!;

          // --- Layout Interpolation ---

          final currentHeight = lerpDouble(_barHeight, screenHeight, value)!;

          // Calculate collapsed state values
          final availableWidth = screenWidth - widget.leftOffset;
          final collapsedWidth = (availableWidth - (margin * 2)).clamp(
            0.0,
            1200.0,
          );
          final collapsedLeft =
              widget.leftOffset + (availableWidth - collapsedWidth) / 2;

          final currentWidth = lerpDouble(collapsedWidth, screenWidth, value)!;

          final currentLeft = lerpDouble(collapsedLeft, 0, value)!;
          final currentBottom = lerpDouble(
            widget.bottomOffset + margin,
            0,
            value,
          )!;

          // Opacities
          final fullOpacity = ((value - 0.2) * 5).clamp(0.0, 1.0);

          // Art Layout
          final artSize = lerpDouble(_miniArtSize, fullArtSize, value)!;
          final startArtTop = 13.3; // Perfectly centered in 80px bar: (80-50)/2
          final artTop = lerpDouble(
            startArtTop,
            60 + currentTopPadding,
            value,
          )!;
          final artLeft = lerpDouble(
            startArtLeft,
            (screenWidth - fullArtSize) / 2,
            value,
          )!;

          return Positioned(
            left: currentLeft,
            width: currentWidth,
            bottom: currentBottom,
            height: currentHeight,
            child: PopScope(
              canPop: value == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (value > 0) {
                  _controller.animateTo(
                    0.0,
                    curve: Curves.fastLinearToSlowEaseIn,
                  );
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                onTap: () {
                  if (_controller.value < 0.5) {
                    _controller.animateTo(
                      1.0,
                      curve: Curves.fastLinearToSlowEaseIn,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color.fromARGB(170, 17, 23, 28),
                      const Color(0xFF0D1117),
                      value,
                    ),
                    borderRadius: BorderRadius.circular(
                      lerpDouble(50, 0, value)!,
                    ),
                    border: Border.all(
                      color: Color.lerp(
                        const Color.fromARGB(38, 255, 239, 175),
                        Colors.transparent,
                        value,
                      )!,
                      width: lerpDouble(2, 0, value)!,
                    ),
                    boxShadow: [
                      if (value > 0)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 1. Full Screen Background
                      if (currentSong != null)
                        _buildBackground(currentSong, fullOpacity),

                      Positioned.fill(
                        child: Stack(
                          children: [
                            // 2. Album Art
                            Positioned(
                              top: artTop,
                              left: artLeft,
                              width: artSize,
                              height: artSize,
                              child: Watch((context) {
                                final position = audioSignal.position.value;
                                return _buildMorphingArt(
                                  value,
                                  artSize,
                                  isPlaying,
                                  duration,
                                  position,
                                );
                              }),
                            ),

                            // 3. Song Info (Text)
                            _buildMorphingText(
                              value,
                              screenWidth,
                              fullArtSize,
                              currentSong,
                              isPlaying,
                              currentTopPadding,
                            ),

                            // 4. Playback Controls
                            _buildMorphingControls(
                              value,
                              screenWidth,
                              screenHeight,
                              collapsedWidth,
                              contentTopStart + currentTopPadding,
                              isPlaying,
                              isCompact,
                              currentBottomPadding,
                            ),

                            // 5. Seekbar
                            Watch((context) {
                              final position = audioSignal.position.value;
                              return _buildMorphingSeekbar(
                                isMobile,
                                value,
                                position,
                                duration,
                                contentTopStart + currentTopPadding,
                                screenWidth,
                              );
                            }),

                            // 6. Right Actions (Desktop only)
                            _buildMorphingRightActions(
                              value,
                              screenWidth,
                              collapsedWidth,
                              isCompact,
                            ),

                            // 7. Expanded Content (Pinned to bottom)
                            if (value > 0.5)
                              _buildMobileExpanded(
                                currentSong,
                                isPlaying,
                                duration,
                                Duration.zero, // Position handled by seekbar
                                contentTopStart + currentTopPadding,
                                value,
                                26.0, // Consistent icon size (26px)
                                currentBottomPadding,
                              ),
                          ],
                        ),
                      ),

                      // 7. Collapse Button (Outside SafeArea to stay at top)
                      if (fullOpacity > 0)
                        Positioned(
                          top: 8 + currentTopPadding,
                          left: screenWidth / 2 - 24,
                          child: Opacity(
                            opacity: fullOpacity,
                            child: IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFFFCE7AC),
                                size: 24,
                              ),
                              onPressed: () => _controller.animateTo(
                                0.0,
                                curve: Curves.fastLinearToSlowEaseIn,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBackground(Song currentSong, double fullOpacity) {
    if (_currentAlbumArt == null || fullOpacity <= 0)
      return const SizedBox.shrink();
    return Positioned.fill(
      child: Opacity(
        opacity: fullOpacity,
        child: RepaintBoundary(
          child: Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Image.file(_currentAlbumArt!, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D1117).withOpacity(0.5),
                        const Color(0xFF0D1117).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMorphingSeekbar(
    bool isMobile,
    double value,
    Duration position,
    Duration duration,
    double contentTopStart,
    double screenWidth,
  ) {
    if (value < 0.9) return const SizedBox.shrink();

    return Positioned(
      top: contentTopStart,
      left: isMobile ? 32 : screenWidth / 2 - 280,
      right: isMobile ? 32 : screenWidth / 2 - 280,
      child: Opacity(
        opacity: ((value - 0.9) * 10).clamp(0.0, 1.0),
        child: Column(
          spacing: 6,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                activeTrackColor: const Color(0xFFFCE7AC),
                inactiveTrackColor: const Color(0xFFFCE7AC).withOpacity(0.3),
                thumbColor: const Color(0xFFFCE7AC),
              ),
              child: Slider(
                value:
                    (position.inMilliseconds /
                            (duration.inMilliseconds > 0
                                ? duration.inMilliseconds
                                : 1))
                        .clamp(0.0, 1.0),
                onChanged: (v) {
                  final pos = v * duration.inMilliseconds;
                  audioSignal.seek(Duration(milliseconds: pos.round()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Color(0x9FFCE7AC),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Color(0x9FFCE7AC),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphingText(
    double value,
    double screenWidth,
    double fullArtSize,
    Song? currentSong,
    bool isPlaying,
    double currentTopPadding,
  ) {
    final isMobile = screenWidth < 600;
    final isCompact = isMobile;
    final startArtLeft = isCompact
        ? _compactPadding
        : _fullPadding + _leftControlsWidth + _artSpacing;

    final fixedStartLeft = startArtLeft + 50.0 + 16;
    final fixedStartHeight = 50.0; // Perfectly match art height
    final fixedStartTop = 13.0; // Perfectly centered in 80px bar: (80-50)/2

    // Calculate start width based on layout (Compact vs Full)
    final rightControlsWidth = isCompact
        ? 160.0
        : 260.0; // Increased for desktop
    final availableWidth = screenWidth - widget.leftOffset;
    final margin = isCompact ? _compactMargin : _fullMargin;
    final collapsedWidth = (availableWidth - (margin * 2)).clamp(0.0, 1200.0);
    final fixedStartWidth =
        collapsedWidth - fixedStartLeft - rightControlsWidth;

    // End State (Value = 1)
    final screenHeight = MediaQuery.of(context).size.height;
    final fixedEndHeight = 60.0;
    final fixedEndTop = 90.0 + fullArtSize + currentTopPadding;
    final fixedEndWidth = screenWidth - 60; // Padding (32*2)
    final fixedEndLeft = 32.0;

    // Interpolation
    final currentLeft = lerpDouble(fixedStartLeft, fixedEndLeft, value)!;
    final currentTop = lerpDouble(fixedStartTop, fixedEndTop, value)!;
    final currentWidth = lerpDouble(fixedStartWidth, fixedEndWidth, value)!;
    final currentHeight = lerpDouble(fixedStartHeight, fixedEndHeight, value)!;

    // Text Styles
    final titleStyle = TextStyle.lerp(
      const TextStyle(
        color: Color(0xFFFCE7AC),
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.2,
      ),
      const TextStyle(
        color: Color(0xFFFCE7AC),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      value,
    )!;

    final artistStyle = TextStyle.lerp(
      const TextStyle(
        color: Color.fromARGB(204, 252, 231, 172),
        fontSize: 14,
        height: 1.2,
      ),
      const TextStyle(
        color: Color.fromARGB(180, 252, 231, 172),
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.2,
      ),
      value,
    )!;

    return Positioned(
      left: currentLeft,
      top: currentTop,
      width: currentWidth,
      height: currentHeight,
      child: RepaintBoundary(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.9, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ClipRect(
                    child: Column(
                      spacing: _controller.value <= 0.5 ? 0 : 1,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        value > 0.5
                            ? MarqueeText(
                                text: currentSong?.title ?? 'No song playing',
                                style: titleStyle,
                                isPlaying: isPlaying,
                              )
                            : Text(
                                currentSong?.title ?? 'No song playing',
                                style: titleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        SizedBox(height: 6),
                        Text(
                          currentSong?.artist ?? '',
                          style: artistStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (value > 0.5)
                Opacity(
                  opacity: ((value - 0.5) * 2).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const FaIcon(
                        FontAwesomeIcons.heart,
                        color: Color(0xFFFCE7AC),
                        size: 24,
                      ),
                      onPressed: () {}, // TODO: Implement favorites
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMorphingRightActions(
    double value,
    double screenWidth,
    double collapsedWidth,
    bool isCompact,
  ) {
    if (isCompact) return const SizedBox.shrink();

    // Desktop Layout: Right aligned in collapsed bar
    final startRight = _fullPadding;
    final startTop = (_barHeight / 2) - 21;

    // Fade out as we expand
    final opacity = (1.0 - value * 5).clamp(0.0, 1.0);
    if (opacity == 0) return const SizedBox.shrink();

    return Positioned(
      top: startTop,
      right: startRight,
      child: Opacity(
        opacity: opacity,
        child: Watch((context) {
          final isShuffle = audioSignal.isShuffleMode.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Color(0xFFFCE7AC),
                  size: 24, // Consistent 24px
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.listUl,
                  color: Color(0xFFFCE7AC),
                  size: 24, // Consistent 24px
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.repeat,
                  color: Color(0xFFFCE7AC),
                  size: 24, // Consistent 24px
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.shuffle,
                  color: isShuffle
                      ? const Color(0xFFFCE7AC)
                      : const Color.fromARGB(100, 252, 231, 172),
                  size: 24, // Consistent 24px
                ),
                onPressed: audioSignal.toggleShuffle,
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.volumeHigh,
                  color: Color(0xFFFCE7AC),
                  size: 24, // Consistent 24px
                ),
                onPressed: () {},
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMorphingArt(
    double value,
    double artSize,
    bool isPlaying,
    Duration duration,
    Duration position,
  ) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress (Mini only)
          if (value == 0)
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                strokeWidth: 3,
                backgroundColor: const Color.fromARGB(51, 255, 239, 175),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(204, 255, 239, 175),
                ),
              ),
            ),

          // Art / Play Button
          GestureDetector(
            onTap: () {
              if (value == 0) {
                if (isPlaying)
                  audioSignal.pause();
                else
                  audioSignal.play();
              }
            },
            child: Hero(
              tag: 'player-artwork',
              child: Container(
                width: value == 0 ? 42 : artSize,
                height: value == 0 ? 42 : artSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(value == 0 ? 50 : 12),
                  boxShadow: [
                    if (value > 0.5)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(value == 0 ? 50 : 12),
                  child: _currentAlbumArt != null
                      ? Image.file(_currentAlbumArt!, fit: BoxFit.cover)
                      : (value == 0)
                      ? Center(
                          child: FaIcon(
                            isPlaying
                                ? FontAwesomeIcons.pause
                                : FontAwesomeIcons.play,
                            color: const Color(0xFFFCE7AC),
                            size: 16,
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorphingControls(
    double value,
    double screenWidth,
    double screenHeight,
    double collapsedWidth,
    double contentTopStart,
    bool isPlaying,
    bool isCompact,
    double currentBottomPadding,
  ) {
    // Start State (Mini)
    double startRight;
    double startLeft;
    double startTop = _startTop;

    double startWidth;
    double startPlayBtnSize;
    double startPlayBtnOpacity;

    if (isCompact) {
      // Mobile: Right aligned, Play button hidden
      startRight = 0;
      startWidth = _leftControlsWidth - 28;
      startLeft = collapsedWidth - startRight - startWidth;
      startPlayBtnSize = 0;
      startPlayBtnOpacity = 0;
    } else {
      // Desktop: Left aligned, Play button visible (just icon)
      startLeft = 3;
      startWidth = _leftControlsWidth;
      startPlayBtnSize = 24; // Enough for icon, background transparent
      startPlayBtnOpacity = 0;
    }

    // End State (Full)
    // Centered between seekbar and bottom section
    // Seekbar is at contentTopStart + 20, height ~80
    final seekbarBottom = contentTopStart;
    // Bottom section is roughly 126px from bottom + currentBottomPadding
    final bottomSectionTop = screenHeight - currentBottomPadding;
    final midPoint = (seekbarBottom + bottomSectionTop) / 2;
    final endTop = midPoint - 90; // Center the 64px controls
    final endWidth = screenWidth;
    final endLeft = 0.0;

    // Interpolate
    final currentLeft = lerpDouble(startLeft, endLeft, value)!;
    final currentTop = lerpDouble(startTop, endTop, value)!;
    final currentWidth = lerpDouble(startWidth, endWidth, value)!;

    // Button Spacing
    final spacing = lerpDouble(8, 40, value)!;
    final buttonPadding = EdgeInsets.lerp(
      const EdgeInsets.all(6),
      const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      value,
    )!;

    // Play Button Size/Opacity
    final playBtnSize = lerpDouble(startPlayBtnSize, 56, value)!;
    final playBtnOpacity = lerpDouble(startPlayBtnOpacity, 1.0, value)!;

    // Icon Size
    final startIconSize = isCompact
        ? 0.0
        : 24.0; // Standardized to 24px for desktop
    final iconSize = lerpDouble(startIconSize, 24, value)!;

    // Icon Color
    final iconOpacity = isCompact ? value : 1.0;

    return Positioned(
      top: currentTop,
      left: currentLeft,
      width: currentWidth,
      child: RepaintBoundary(
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Always center to prevent snapping
          children: [
            IconButton(
              padding: buttonPadding,
              icon: FaIcon(
                FontAwesomeIcons.backwardStep,
                color: const Color(0xFFFCE7AC),
                size: lerpDouble(isCompact ? 24 : 24, 40, value)!,
              ),
              onPressed: audioSignal.skipPrevious,
            ),

            // Play/Pause Button (Morphing)
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: playBtnSize >= 24
                  ? IconButton(
                      // Hide if too small
                      padding: buttonPadding,
                      icon: FaIcon(
                        isPlaying
                            ? FontAwesomeIcons.pause
                            : FontAwesomeIcons.play,
                        color: const Color(0xFFFCE7AC),
                        size: playBtnSize,
                      ),
                      onPressed: () {
                        if (isPlaying)
                          audioSignal.pause();
                        else
                          audioSignal.play();
                      },
                    )
                  : null,
            ),

            IconButton(
              padding: buttonPadding,
              icon: FaIcon(
                FontAwesomeIcons.forwardStep,
                color: const Color(0xFFFCE7AC),
                size: lerpDouble(isCompact ? 24 : 24, 40, value)!,
              ),
              onPressed: audioSignal.skipNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileExpanded(
    Song? currentSong,
    bool isPlaying,
    Duration duration,
    Duration position,
    double contentTopStart,
    double value,
    double iconSize,
    double currentBottomPadding,
  ) {
    final opacity = ((value - 0.5) * 2).clamp(0.0, 1.0);

    return Positioned(
      bottom: currentBottomPadding + 22,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Format Badge
            if (currentSong != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7AC),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFFCE7AC).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '${currentSong.path.split('.').last.toUpperCase()} | ${currentSong.bitrate ?? '---'}Kbps',
                  style: const TextStyle(
                    color: Color(0xFF21282D),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centered
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.shuffle,
                    color: Color(0xFFFCE7AC),
                    size: 24,
                  ),
                  onPressed: audioSignal.toggleShuffle,
                ),
                const SizedBox(width: 12), // Fixed gap
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.repeat,
                    color: Color(0xFFFCE7AC),
                    size: 24,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 12), // Fixed gap
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.listUl,
                    color: Color(0xFFFCE7AC),
                    size: 24,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 12), // Fixed gap
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.volumeHigh,
                    color: Color(0xFFFCE7AC),
                    size: 24,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 12), // Fixed gap
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.ellipsis,
                    color: Color(0xFFFCE7AC),
                    size: 24,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
