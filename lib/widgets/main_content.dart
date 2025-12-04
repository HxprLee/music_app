import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'cards.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Navigation Arrows
              _buildNavIcon(Icons.chevron_left),
              const SizedBox(width: 8),
              _buildNavIcon(Icons.chevron_right),

              const SizedBox(width: 24),

              // Search Bar
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 24, 27, 34),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Search songs, albums, artists',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Window Controls
              _buildWindowControl(Icons.keyboard_arrow_down),
              const SizedBox(width: 8),
              _buildWindowControl(Icons.keyboard_arrow_up),
              const SizedBox(width: 8),
              _buildWindowControl(Icons.close),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              final recentlyAdded = audioProvider.recentlyAdded;
              final recentlyPlayed = audioProvider.recentlyPlayed;
              final isScanning = audioProvider.isScanning;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCE7AC),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions - Horizontal Scrollable
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          QuickActionCard(
                            icon: Icons.favorite,
                            label: 'Favorites',
                          ),
                          SizedBox(width: 16),
                          QuickActionCard(
                            icon: Icons.history,
                            label: 'Recently played',
                          ),
                          SizedBox(width: 16),
                          QuickActionCard(
                            icon: Icons.repeat,
                            label: 'Most played',
                          ),
                          SizedBox(width: 16),
                          QuickActionCard(
                            icon: Icons.playlist_play,
                            label: 'Playlists',
                          ),
                          SizedBox(width: 16),
                          QuickActionCard(
                            icon: Icons.shuffle,
                            label: 'Shuffle',
                          ),
                          SizedBox(width: 16),
                          QuickActionCard(
                            icon: Icons.add,
                            label: 'Add shortcuts',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recently Added Songs
                    Row(
                      children: [
                        const Text(
                          "Recently added songs",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        if (isScanning)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: recentlyAdded.isEmpty
                          ? Center(
                              child: Text(
                                isScanning
                                    ? 'Scanning music directory...'
                                    : 'No songs found in ~/Music',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentlyAdded.length,
                              itemBuilder: (context, index) {
                                final song = recentlyAdded[index];
                                return SongCard(
                                  title: song.title,
                                  artist: song.artist,
                                  albumArt: song.albumArt,
                                  color: _getColorForIndex(index),
                                  onTap: () => audioProvider.playSong(song),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Recently Played
                    const Text(
                      "Recently played",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: recentlyPlayed.isEmpty
                          ? const Center(
                              child: Text(
                                'No recently played songs',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentlyPlayed.length,
                              itemBuilder: (context, index) {
                                final song = recentlyPlayed[index];
                                return SongCard(
                                  title: song.title,
                                  artist: song.artist,
                                  albumArt: song.albumArt,
                                  color: _getColorForIndex(index + 3),
                                  onTap: () => audioProvider.playSong(song),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 120), // Padding for PlayerBar
      ],
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF282C34),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white54, size: 18),
    );
  }

  Widget _buildWindowControl(IconData icon) {
    return Icon(icon, color: Colors.white54, size: 20);
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.purple,
      Colors.amber,
      Colors.deepPurple,
      Colors.blueGrey,
      Colors.teal,
      Colors.cyan,
      Colors.orange,
      Colors.indigo,
      Colors.pink,
      Colors.blue,
    ];
    return colors[index % colors.length];
  }
}
