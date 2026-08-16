// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../signals/audio_signal.dart';
import '../services/song_cache.dart';
import '../models/song.dart';
import '../models/history_entry.dart';
import '../widgets/components/sliver_page_header.dart';
import '../widgets/components/song_list_view.dart';
import '../widgets/components/song_tile.dart';
import '../widgets/components/song_grid_card.dart';
import '../widgets/components/standard_sliver_grid.dart';

class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  String? _artDirPath;

  @override
  void initState() {
    super.initState();
    _initArtDir();
  }

  Future<void> _initArtDir() async {
    final path = await SongCache.artDir;
    if (mounted) {
      setState(() {
        _artDirPath = path;
      });
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SignalBuilder(builder: (context) {
        // Use audioSignal.historySongs — the same source as Home screen's
        // "Recently played" section. History is ordered most-recent-first.
        final historyEntries = audioSignal.historySongs.value;
        final songs = audioSignal.allSongs.value;
        final songMap = {for (final s in songs) s.path: s};
        final isGrid = audioSignal.isHistoryGridView.value;

        return CustomScrollView(
          slivers: [
            SliverPageHeader(
              title: 'Recently Played',
              actions: [
                IconButton(
                  onPressed: () =>
                      audioSignal.isHistoryGridView.value = !isGrid,
                  icon: FaIcon(
                    isGrid
                        ? FontAwesomeIcons.list
                        : FontAwesomeIcons.borderAll,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (historyEntries.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No songs played yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ),
              )
            else if (isGrid)
              StandardSliverGrid<HistoryEntry>(
                items: historyEntries,
                childAspectRatio: 0.75,
                itemBuilder: (context, entry, index) {
                  final song = songMap[entry.songPath] ??
                      Song.fromPath(entry.songPath);

                  return SongGridCard(
                    song: song,
                    subtitle: '${entry.playCount} plays',
                    artPath: SongTile.getArtPath(song.path, _artDirPath),
                    onTap: () => audioSignal.playSong(song),
                  );
                },
              )
            else
              SongListView(
                songs: historyEntries
                    .map((e) => songMap[e.songPath] ?? Song.fromPath(e.songPath))
                    .toList(),
                emptyMessage: 'No songs played yet',
                trailingBuilder: (context, song, index) {
                  final entry = historyEntries[index];
                  return Text(
                    _formatRelativeTime(entry.lastPlayed),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                      fontSize: 12,
                    ),
                  );
                },
              ),
          ],
        );
      }),
    );
  }
}

// Deleted _GridSongCard
