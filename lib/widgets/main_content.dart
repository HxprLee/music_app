import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              _buildNavIcon(FontAwesomeIcons.chevronLeft),
              const SizedBox(width: 8),
              _buildNavIcon(FontAwesomeIcons.chevronRight),

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
                      const FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.white54,
                        size: 16,
                      ),
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
              _buildWindowControl(FontAwesomeIcons.minus),
              const SizedBox(width: 8),
              _buildWindowControl(FontAwesomeIcons.windowMaximize),
              const SizedBox(width: 8),
              _buildWindowControl(FontAwesomeIcons.xmark),
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFCE7AC),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions - Horizontal Scrollable
                    SizedBox(
                      height: 85,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          QuickActionCard(
                            icon: FontAwesomeIcons.solidHeart,
                            label: 'Favorites',
                          ),
                          SizedBox(width: 8),
                          QuickActionCard(
                            icon: FontAwesomeIcons.clockRotateLeft,
                            label: 'Recently played',
                          ),
                          SizedBox(width: 8),
                          QuickActionCard(
                            icon: FontAwesomeIcons.repeat,
                            label: 'Most played',
                          ),
                          SizedBox(width: 8),
                          QuickActionCard(
                            icon: FontAwesomeIcons.list,
                            label: 'Playlists',
                          ),
                          SizedBox(width: 8),
                          QuickActionCard(
                            icon: FontAwesomeIcons.shuffle,
                            label: 'Shuffle',
                          ),
                          SizedBox(width: 8),
                          QuickActionCard(
                            icon: FontAwesomeIcons.plus,
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(204, 252, 231, 172),
                          ),
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
                    const SizedBox(height: 12),
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
                                  songPath: song.path,
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(204, 252, 231, 172),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                  songPath: song.path,
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
      child: Center(child: FaIcon(icon, color: Colors.white54, size: 14)),
    );
  }

  Widget _buildWindowControl(IconData icon) {
    return FaIcon(icon, color: Colors.white54, size: 16);
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
