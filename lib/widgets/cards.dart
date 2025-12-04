import 'dart:typed_data';
import 'package:flutter/material.dart';

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
        width: 160,
        height: 80,
        padding: const EdgeInsets.all(12),
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
            Icon(widget.icon, color: Colors.white70, size: 20),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w200,
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
  final Uint8List? albumArt;
  final Color color;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.color,
    this.onTap,
  });

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool _isHovered = false;

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
                      image: widget.albumArt != null
                          ? DecorationImage(
                              image: MemoryImage(widget.albumArt!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.albumArt == null
                        ? Center(
                            child: Icon(
                              Icons.music_note,
                              size: 48,
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
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
