import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../widgets/sidebar.dart';
import '../widgets/morphing_player.dart';
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
              top: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(child: widget.child),
            ),

            // Sidebar (Desktop only) - Moved to top layer
            if (!isMobile)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Sidebar(
                  isCollapsed: _isSidebarCollapsed,
                  onToggle: _toggleSidebar,
                ),
              ),

            // Morphing Player - Moved to end of stack to be on top of everything
            MorphingPlayer(leftOffset: contentLeftOffset),
          ],
        ),
        bottomNavigationBar: isMobile
            ? Watch((context) {
                final expansion = audioSignal.playerExpansion.value;
                final height = 80 * (1 - expansion);

                return Container(
                  height: height,
                  color: const Color(0xFF11171C),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: 80,
                      minHeight: 80,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(canvasColor: const Color(0xFF11171C)),
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
                          backgroundColor: const Color(0xFF11171C),
                          selectedItemColor: const Color(0xFFFCE7AC),
                          unselectedItemColor: Colors.white54,
                          type: BottomNavigationBarType.fixed,
                          items: const [
                            BottomNavigationBarItem(
                              icon: FaIcon(FontAwesomeIcons.house, size: 20),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: FaIcon(FontAwesomeIcons.youtube, size: 20),
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
                              icon: FaIcon(FontAwesomeIcons.gear, size: 20),
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
