// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../signals/audio_signal.dart';
import '../../signals/overlay_signal.dart';
import '../components/flyout_sheet.dart';
import '../mobile_lyrics_view.dart';

void showLyricsSheet(BuildContext context) {
  overlaySignal.push(ActiveOverlay.lyrics);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    isScrollControlled: true,
    useRootNavigator: true,
    sheetAnimationStyle: AnimationStyle(
      curve: const Cubic(0.68, 0.01, 0.55, 0.99),
      duration: const Duration(milliseconds: 500),
    ),
    useSafeArea: true,
    builder: (context) {
      return const LyricsSheet();
    },
  );
}

class LyricsSheet extends StatefulWidget {
  const LyricsSheet({super.key});

  @override
  State<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<LyricsSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FlyoutSheet(
      mainAxisSize: MainAxisSize.max,
      safeAreaTop: true,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
            child: Row(
              children: [
                Text(
                  'Lyrics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.secondary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Lyrics Content
          Expanded(
            child: SignalBuilder(builder: (context) {
              final lyrics = audioSignal.currentLyrics.value;
              final hasLyrics = lyrics != null;

              if (!hasLyrics) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lyrics_outlined,
                        size: 48,
                        color: colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No lyrics available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return MobileLyricsView(lyricsText: lyrics);
            }),
          ),
        ],
      ),
    );
  }
}
