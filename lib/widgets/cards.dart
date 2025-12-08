import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/album_art_cache.dart';

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;

  const QuickActionCard({super.key, required this.icon, required this.label});

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: 150,
        height: 85,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color.fromARGB(102, 17, 23, 28)
              : const Color.fromARGB(178, 17, 23, 28),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromARGB(38, 255, 239, 175)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FaIcon(
              widget.icon,
              color: Color.fromARGB(255, 252, 231, 172),
              size: 18,
            ),
            Text(
              widget.label,
              style: const TextStyle(
                color: Color.fromARGB(204, 252, 231, 172),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongCard extends StatefulWidget {
  final String title;
  final String artist;
  final String? songPath; // Use path for lazy loading
  final Color color;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    this.songPath,
    required this.color,
    this.onTap,
  });

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool _isHovered = false;
  Uint8List? _albumArt;
  bool _artLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAlbumArt();
  }

  @override
  void didUpdateWidget(SongCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songPath != widget.songPath) {
      _artLoaded = false;
      _albumArt = null;
      _loadAlbumArt();
    }
  }

  Future<void> _loadAlbumArt() async {
    if (widget.songPath == null || _artLoaded) return;

    final art = await AlbumArtCache().getArt(widget.songPath!);
    if (mounted) {
      setState(() {
        _albumArt = art;
        _artLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 180,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album Art
              Stack(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(8),
                      image: _albumArt != null
                          ? DecorationImage(
                              image: MemoryImage(_albumArt!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _albumArt == null
                        ? Center(
                            child: FaIcon(
                              FontAwesomeIcons.music,
                              size: 36,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          )
                        : null,
                  ),
                  if (_isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.play,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromARGB(255, 252, 231, 172),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                widget.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color.fromARGB(204, 252, 231, 172),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
