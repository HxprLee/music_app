import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isCollapsed = false;
  double? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;

    if (_lastWidth == null) {
      // Initial state based on current width
      _isCollapsed = width < 1200;
    } else {
      // Check for breakpoint crossing
      if (_lastWidth! >= 1200 && width < 1200) {
        // Crossed to smaller screen -> collapse
        _isCollapsed = true;
      } else if (_lastWidth! < 1200 && width >= 1200) {
        // Crossed to larger screen -> expand
        _isCollapsed = false;
      }
    }
    _lastWidth = width;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isCollapsed ? 70 : 250,
        decoration: BoxDecoration(
          color: const Color.fromARGB(178, 17, 23, 28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color.fromARGB(38, 255, 239, 175),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: _isCollapsed ? 8 : 16,
        ),
        child: Column(
          crossAxisAlignment: _isCollapsed
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            // Menu Icon
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: _toggleCollapse,
            ),
            const SizedBox(height: 20),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: _isCollapsed
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    // Pinned Section
                    if (!_isCollapsed) _buildSectionTitle('Pinned'),
                    _buildNavItem(
                      Icons.home_filled,
                      'Home',
                      isSelected: true,
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.music_note,
                      'YouTube Music',
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.library_music,
                      'Library',
                      isCollapsed: _isCollapsed,
                    ),
                    const Divider(color: Colors.white10, height: 32),

                    // Library Section
                    if (!_isCollapsed) _buildSectionTitle('Library'),
                    _buildNavItem(
                      Icons.album,
                      'Albums',
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.music_note_outlined,
                      'Songs',
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.playlist_play,
                      'Playlists',
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.person,
                      'Artists',
                      isCollapsed: _isCollapsed,
                    ),
                    _buildNavItem(
                      Icons.download_done,
                      'Downloaded',
                      isCollapsed: _isCollapsed,
                    ),
                    const Divider(color: Colors.white10, height: 32),

                    // Playlists Section (Placeholder)
                    if (!_isCollapsed) _buildSectionTitle('Playlists'),

                    const SizedBox(height: 100), // Space before settings
                  ],
                ),
              ),
            ),

            // Settings (always visible at bottom)
            _buildNavItem(
              Icons.settings,
              'Settings',
              isCollapsed: _isCollapsed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title, {
    bool isSelected = false,
    required bool isCollapsed,
  }) {
    if (isCollapsed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE7AC) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Tooltip(
          message: title,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: isSelected ? Colors.black87 : Colors.white70,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFCE7AC) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.black87 : Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
