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

class MostPlayedScreen extends StatefulWidget {
  const MostPlayedScreen({super.key});

  @override
  State<MostPlayedScreen> createState() => _MostPlayedScreenState();
}

class _MostPlayedScreenState extends State<MostPlayedScreen> {
  String? _artDirPath;
  final _isGrid = signal(false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SignalBuilder(builder: (context) {
        // historySongs is already sorted by lastPlayed. We want most played.
        final historyList = List<HistoryEntry>.from(audioSignal.historySongs.value);
        historyList.sort((a, b) => b.playCount.compareTo(a.playCount));
        
        final songs = audioSignal.allSongs.value;
        final isGrid = _isGrid.value;

        return CustomScrollView(
          slivers: [
            SliverPageHeader(
              title: 'Most Played',
              actions: [
                IconButton(
                  onPressed: () => _isGrid.value = !isGrid,
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
            if (historyList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No songs played yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ),
              )
            else if (isGrid)
              StandardSliverGrid<HistoryEntry>(
                items: historyList,
                childAspectRatio: 0.75,
                itemBuilder: (context, entry, index) {
                  final song = songs.firstWhere(
                    (s) => s.path == entry.songPath,
                    orElse: () => Song.fromPath(entry.songPath),
                  );

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
                songs: historyList
                    .map(
                      (e) => songs.firstWhere(
                        (s) => s.path == e.songPath,
                        orElse: () => Song.fromPath(e.songPath),
                      ),
                    )
                    .toList(),
                emptyMessage: 'No songs played yet',
                trailingBuilder: (context, song, index) {
                  final entry = historyList[index];
                  return Text(
                    '${entry.playCount} plays',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
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