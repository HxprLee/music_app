import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/main_content.dart';
import '../widgets/player_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarCollapsed = false;
  double? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1000;

    // Dimensions
    const collapsedWidth = 70.0 + 16.0; // 70 width + 16 margin
    const expandedWidth = 250.0 + 16.0; // 250 width + 16 margin

    // Calculate content left offset
    double contentLeftOffset;
    if (isSmallScreen) {
      // Small screen: content always offset by collapsed width
      contentLeftOffset = collapsedWidth;
    } else {
      // Large screen: content offset depends on sidebar state
      contentLeftOffset = _isSidebarCollapsed ? collapsedWidth : expandedWidth;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: contentLeftOffset,
            top: 0,
            right: 0,
            bottom: 0,
            child: const Stack(
              children: [
                MainContent(),
                Align(alignment: Alignment.bottomCenter, child: PlayerBar()),
              ],
            ),
          ),

          // Sidebar
          // We don't need AnimatedPositioned here because the Sidebar widget itself
          // handles its width animation. We just need to position it at left: 0.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Sidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: _toggleSidebar,
            ),
          ),
        ],
      ),
    );
  }
}
