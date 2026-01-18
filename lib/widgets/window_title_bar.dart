import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';
import '../signals/audio_signal.dart';
import '../signals/settings_signal.dart';

class WindowTitleBar extends StatefulWidget {
  final double leftPadding;

  const WindowTitleBar({super.key, this.leftPadding = 0});

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: audioSignal.searchQuery.value,
    );

    // Sync controller with signal
    effect(() {
      final query = audioSignal.searchQuery.value;
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (!settingsSignal.useCustomWindowControls.value) {
        return const SizedBox.shrink();
      }

      final expansion = audioSignal.playerExpansion.value;
      final hideContentOpacity = (1 - expansion * 2).clamp(0.0, 1.0);

      return WindowTitleBarBox(
        child: Container(
          height: 80,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Left: Navigation Buttons
              Opacity(
                opacity: hideContentOpacity,
                child: IgnorePointer(
                  ignoring: expansion > 0.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sidebar spacing (content offset)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        width: widget.leftPadding,
                      ),
                      const SizedBox(width: 16),
                      _CircularIconButton(
                        icon: Icons.chevron_left,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                      _CircularIconButton(
                        icon: Icons.chevron_right,
                        onPressed: null,
                        tooltip: 'Forward',
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable area
              Expanded(child: MoveWindow()),

              // Center: Search Bar
              Opacity(
                opacity: hideContentOpacity,
                child: IgnorePointer(
                  ignoring: expansion > 0.5,
                  child: Center(
                    child: Container(
                      height: 40,
                      constraints: const BoxConstraints(maxWidth: 450),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F24),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.escape): () {
                            if (context.canPop()) {
                              context.pop();
                              // Clear search on exit
                              audioSignal.searchQuery.value = '';
                            }
                          },
                        },
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) =>
                              audioSignal.searchQuery.value = value,
                          onTap: () {
                            final location = GoRouterState.of(
                              context,
                            ).uri.toString();
                            if (location != '/search') {
                              context.push('/search');
                            }
                          },
                          onSubmitted: (value) {
                            final location = GoRouterState.of(
                              context,
                            ).uri.toString();
                            if (location != '/search') {
                              context.push('/search');
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search songs, albums, artists',
                            hintStyle: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white38,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Draggable area
              Expanded(child: MoveWindow()),

              // Right: Window Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [const WindowButtons(), const SizedBox(width: 16)],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _CircularIconButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          cursor: onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null ? Colors.white70 : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircularWindowButton(
          icon: Icons.keyboard_arrow_down,
          onPressed: () => appWindow.minimize(),
          tooltip: 'Minimize',
        ),
        const SizedBox(width: 8),
        _CircularWindowButton(
          icon: Icons.keyboard_arrow_up,
          onPressed: () => appWindow.maximizeOrRestore(),
          tooltip: 'Maximize',
        ),
        const SizedBox(width: 8),
        _CircularWindowButton(
          icon: Icons.close,
          onPressed: () async {
            if (settingsSignal.backgroundPlayback.value) {
              await windowManager.hide();
            } else {
              appWindow.close();
            }
          },
          tooltip: 'Close',
          isClose: true,
        ),
      ],
    );
  }
}

class _CircularWindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isClose;

  const _CircularWindowButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: Icon(icon, size: 18, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
