import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../widgets/sidebar.dart';
import '../widgets/morphing_player.dart';
import '../widgets/window_title_bar.dart';
import '../signals/audio_signal.dart';

/// Shell widget that wraps all routes with common UI elements:
/// - Sidebar (desktop)
/// - MorphingPlayer (bottom bar)
/// - BottomNavigationBar (mobile)
class HomeShell extends StatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _playerKey = GlobalKey();
  bool _isSidebarCollapsed = false;
  double? _lastWidth;

  bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isDesktop) {
      final width = MediaQuery.of(context).size.width;

      if (_lastWidth == null) {
        // Initial state
        _isSidebarCollapsed = width < 1200;
      } else {
        // Handle breakpoint changes
        if (_lastWidth! >= 1200 && width < 1200) {
          _isSidebarCollapsed = true;
        } else if (_lastWidth! < 1200 && width >= 1200) {
          _isSidebarCollapsed = false;
        }
      }
      _lastWidth = width;
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/explorer')) return 2;
    if (location.startsWith('/playlist')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Home
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1000;
    final location = GoRouterState.of(context).uri.toString();

    // Dimensions
    const collapsedWidth = 70.0 + 16.0; // 70 width + 16 margin
    const expandedWidth = 250.0 + 16.0; // 250 width + 16 margin

    // Calculate content left offset
    double contentLeftOffset;
    if (isMobile) {
      contentLeftOffset = 0;
    } else if (isSmallScreen) {
      // Small screen: content always offset by collapsed width
      contentLeftOffset = collapsedWidth;
    } else {
      // Large screen: content offset depends on sidebar state
      contentLeftOffset = _isSidebarCollapsed ? collapsedWidth : expandedWidth;
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = 80.0 + (isMobile ? topPadding : 0);

    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Use go_router to navigate back
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        drawer: isMobile
            ? Drawer(
                backgroundColor: Colors.transparent,
                elevation: 0,
                width: 250 + 16,
                child: Sidebar(
                  isCollapsed: false,
                  onToggle: () {},
                  isDrawer: true,
                ),
              )
            : null,
        body: Stack(
          children: [
            // Main Content (from router)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: contentLeftOffset,
              top: 0, // Allow content to scroll behind header
              right: 0,
              bottom: 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final metrics = notification.metrics;
                    if (metrics.axis == Axis.vertical) {
                      audioSignal.headerShowBlur.value = metrics.pixels > 0;
                    }
                  }
                  return false;
                },
                child: widget.child,
              ),
            ),

            // Title Bar (Always visible now, layout handled internally)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight, // Match design height + SafeArea on mobile
              child: WindowTitleBar(leftOffset: contentLeftOffset),
            ),

            // Sidebar and MorphingPlayer with dynamic Z-index
            Positioned.fill(
              child: Watch((context) {
                final expansion = audioSignal.playerExpansion.value;
                final isExpanded = expansion >= 0.5;

                final sidebar = !isMobile
                    ? Positioned(
                        key: const ValueKey('sidebar'),
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Sidebar(
                          isCollapsed: _isSidebarCollapsed,
                          onToggle: _toggleSidebar,
                        ),
                      )
                    : const SizedBox.shrink();

                const navBarHeight = 80.0;
                final player = MorphingPlayer(
                  key: _playerKey,
                  leftOffset: contentLeftOffset,
                  bottomOffset: isMobile ? navBarHeight : 0.0,
                );

                return Stack(
                  clipBehavior: Clip.none,
                  children: isExpanded ? [sidebar, player] : [player, sidebar],
                );
              }),
            ),

            // Scanning Indicator
            Positioned(
              top: 16,
              right: 16,
              child: Watch((context) {
                if (audioSignal.isScanning.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFCE7AC),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scanning...',
                          style: TextStyle(
                            color: Color(0xFFFCE7AC),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
        bottomNavigationBar: isMobile
            ? Watch((context) {
                final expansion = audioSignal.playerExpansion.value;
                const navBarHeight = 80.0;
                return Transform.translate(
                  offset: Offset(
                    0,
                    expansion * navBarHeight,
                  ), // Slide down as player expands
                  child: Opacity(
                    opacity: (1 - expansion * 2).clamp(0.0, 1.0),
                    child:
                        expansion >
                            0.8 // Hide completely when almost full
                        ? const SizedBox.shrink()
                        : ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: BottomNavigationBar(
                                currentIndex: _getSelectedIndex(location),
                                onTap: (index) {
                                  switch (index) {
                                    case 0: // Home
                                      context.go('/');
                                      break;
                                    case 1: // YouTube Music (placeholder)
                                      // TODO: Implement YouTube Music
                                      break;
                                    case 2: // Library
                                      context.go('/explorer');
                                      break;
                                    case 3: // Settings
                                      context.go('/settings');
                                      break;
                                  }
                                },
                                backgroundColor: const Color(
                                  0xFF11171C,
                                ).withOpacity(0.7),
                                selectedItemColor: const Color(0xFFFCE7AC),
                                unselectedItemColor: Colors.white54,
                                type: BottomNavigationBarType.fixed,
                                items: const [
                                  BottomNavigationBarItem(
                                    icon: FaIcon(
                                      FontAwesomeIcons.house,
                                      size: 20,
                                    ),
                                    label: 'Home',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: FaIcon(
                                      FontAwesomeIcons.youtube,
                                      size: 20,
                                    ),
                                    label: 'YouTube Music',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: FaIcon(
                                      FontAwesomeIcons.recordVinyl,
                                      size: 20,
                                    ),
                                    label: 'Library',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: FaIcon(
                                      FontAwesomeIcons.gear,
                                      size: 20,
                                    ),
                                    label: 'Settings',
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              })
            : null,
      ),
    );
  }
}
