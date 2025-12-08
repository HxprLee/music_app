import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({super.key, required this.isCollapsed, required this.onToggle});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isTextInserted = false;
  bool _isTextVisible = false;
  Timer? _expansionTimer;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _isTextInserted = !widget.isCollapsed;
    _isTextVisible = !widget.isCollapsed;
  }

  @override
  void dispose() {
    _expansionTimer?.cancel();
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      _expansionTimer?.cancel();
      _fadeTimer?.cancel();

      if (widget.isCollapsed) {
        // Collapsing: Hide text immediately
        setState(() {
          _isTextInserted = false;
          _isTextVisible = false;
        });
      } else {
        // Expanding: Wait for width animation then show text
        _expansionTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted && !widget.isCollapsed) {
            setState(() {
              _isTextInserted = true;
            });
            // Small delay to allow render before fading in
            _fadeTimer = Timer(const Duration(milliseconds: 50), () {
              if (mounted && !widget.isCollapsed) {
                setState(() {
                  _isTextVisible = true;
                });
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedWidth = widget.isCollapsed ? 70.0 : 250.0;

        return Container(
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: expandedWidth,
              decoration: BoxDecoration(
                color: const Color.fromARGB(170, 17, 23, 28),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color.fromARGB(38, 255, 239, 175),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Menu Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: widget.isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.bars,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: widget.onToggle,
                        ),
                        if (_isTextInserted)
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isTextVisible ? 1.0 : 0.0,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Text(
                                  'Music',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFCE7AC),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigation Items
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isTextInserted) _buildSectionTitle('Pinned'),
                          _buildNavItem(
                            FontAwesomeIcons.solidHouse,
                            'Home',
                            isSelected: true,
                          ),
                          _buildNavItem(
                            FontAwesomeIcons.youtube,
                            'YouTube Music',
                          ),
                          _buildNavItem(
                            FontAwesomeIcons.recordVinyl,
                            'Library',
                          ),
                          const Divider(color: Colors.white10, height: 32),
                          if (_isTextInserted) _buildSectionTitle('Library'),
                          _buildNavItem(FontAwesomeIcons.compactDisc, 'Albums'),
                          _buildNavItem(FontAwesomeIcons.music, 'Songs'),
                          _buildNavItem(FontAwesomeIcons.list, 'Playlists'),
                          _buildNavItem(FontAwesomeIcons.user, 'Artists'),
                          _buildNavItem(
                            FontAwesomeIcons.circleCheck,
                            'Downloaded',
                          ),
                          const Divider(color: Colors.white10, height: 32),
                          if (_isTextInserted) _buildSectionTitle('Playlists'),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // Settings at bottom
                  _buildNavItem(FontAwesomeIcons.gear, 'Settings'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFCE7AC) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Tooltip(
        message: widget.isCollapsed ? title : '',
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                FaIcon(
                  icon,
                  color: isSelected
                      ? Colors.black87
                      : const Color.fromARGB(255, 252, 231, 172),
                  size: 18,
                ),
                if (_isTextInserted)
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isTextVisible ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? Colors.black87 : Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
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
  }
}
