import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../signals/audio_signal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SongsListContent extends StatelessWidget {
  const SongsListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final songs = audioSignal.allSongs.value;
      final searchResults = audioSignal.searchResults.value;
      final isSearching = audioSignal.searchQuery.value.isNotEmpty;
      final displaySongs = isSearching ? searchResults : songs;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (MediaQuery.of(context).size.width < 600)
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFFFCE7AC),
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      const Text(
                        'Songs',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFCE7AC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(170, 17, 23, 28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(38, 255, 239, 175),
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          audioSignal.searchQuery.value = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists, albums...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        icon: const FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          size: 18,
                          color: Color(0xFFFCE7AC),
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white54,
                                ),
                                onPressed: () =>
                                    audioSignal.searchQuery.value = '',
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Songs List
            Expanded(
              child: displaySongs.isEmpty
                  ? Center(
                      child: Text(
                        isSearching ? 'No results found' : 'No songs found',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: displaySongs.length,
                      itemBuilder: (context, index) {
                        final song = displaySongs[index];
                        final isCurrent =
                            audioSignal.currentSong.value?.path == song.path;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E222B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.music,
                                size: 18,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              color: isCurrent
                                  ? const Color(0xFFFCE7AC)
                                  : Colors.white,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: Text(
                            _formatDuration(song.duration ?? Duration.zero),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => audioSignal.playSong(song),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }
}
