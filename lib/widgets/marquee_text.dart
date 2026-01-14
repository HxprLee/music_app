import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool isPlaying;
  final Duration pauseDuration;
  final double pixelsPerSecond;
  final double gap;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.isPlaying = true,
    this.pauseDuration = const Duration(seconds: 5),
    this.pixelsPerSecond = 80.0,
    this.gap = 50.0,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  double _textWidth = 0;
  int _animationId = 0;
  double _lastAvailableWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTextWidth();
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _calculateTextWidth();
      _restartScrolling();
    } else if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _startScrolling();
      } else {
        _stopScrolling();
      }
    }
  }

  void _calculateTextWidth() {
    final textScaler = MediaQuery.textScalerOf(context);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaler: textScaler,
    )..layout();

    if (_textWidth != textPainter.width) {
      setState(() {
        _textWidth = textPainter.width;
      });
    }
  }

  void _restartScrolling() {
    _animationId++;
    _isScrolling = false;
    if (_scrollController.hasClients) {
      try {
        _scrollController.jumpTo(0);
      } catch (_) {}
    }
    _startScrolling();
  }

  @override
  void dispose() {
    _animationId++;
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    if (!mounted || !widget.isPlaying || _isScrolling) return;

    // Wait for layout and attachment
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted || !widget.isPlaying) return;

    if (!_scrollController.hasClients) {
      // Try again shortly
      Future.delayed(const Duration(milliseconds: 200), _startScrolling);
      return;
    }

    // Check overflow with a small buffer
    if (_textWidth <= _lastAvailableWidth + 1.0) return;

    _runAnimation(_animationId);
  }

  void _runAnimation(int id) async {
    if (_isScrolling || !mounted || !widget.isPlaying) return;
    _isScrolling = true;

    while (mounted && widget.isPlaying && id == _animationId) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted || !widget.isPlaying || id != _animationId) break;
        continue;
      }

      try {
        // Ensure we are at start
        _scrollController.jumpTo(0);

        // Pause at start
        await Future.delayed(widget.pauseDuration);
        if (!mounted ||
            !widget.isPlaying ||
            id != _animationId ||
            !_scrollController.hasClients)
          break;

        // Calculate distance for seamless loop: exactly textWidth + gap
        final distance = _textWidth + widget.gap;
        final duration = Duration(
          milliseconds: (distance / widget.pixelsPerSecond * 1000).toInt(),
        );

        // Scroll forward
        await _scrollController.animateTo(
          distance,
          duration: duration,
          curve: Curves.linear,
        );

        if (!mounted ||
            !widget.isPlaying ||
            id != _animationId ||
            !_scrollController.hasClients)
          break;

        // Jump back to start instantly
        _scrollController.jumpTo(0);

        // Very short delay to let the jump settle
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        // If any scroll error occurs, wait and retry
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (id == _animationId) {
      _isScrolling = false;
    }
  }

  void _stopScrolling() {
    _animationId++;
    _isScrolling = false;
    if (_scrollController.hasClients) {
      try {
        _scrollController.jumpTo(0);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (_lastAvailableWidth != availableWidth) {
          _lastAvailableWidth = availableWidth;
          // Re-check scrolling on layout change
          if (_textWidth > availableWidth + 1.0) {
            Future.microtask(() => _startScrolling());
          } else {
            Future.microtask(() => _stopScrolling());
          }
        }

        if (_textWidth <= availableWidth + 1.0) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Text(widget.text, style: widget.style, maxLines: 1),
              SizedBox(width: widget.gap),
              Text(widget.text, style: widget.style, maxLines: 1),
              SizedBox(width: widget.gap),
            ],
          ),
        );
      },
    );
  }
}
