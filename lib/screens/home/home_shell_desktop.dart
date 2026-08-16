// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../signals/shell_layout_signal.dart';
import '../../services/navigation/back_handler.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/morphing_player.dart';
import '../../widgets/components/window_title_bar.dart';

class HomeShellDesktop extends StatefulWidget {
  final Widget child;
  const HomeShellDesktop({super.key, required this.child});

  @override
  State<HomeShellDesktop> createState() => _HomeShellDesktopState();
}

class _HomeShellDesktopState extends State<HomeShellDesktop> {
  final GlobalKey _playerKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;
  double? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;

    if (_lastWidth == null) {
      _isSidebarCollapsed = width < 1200;
    } else {
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
    const headerHeight = 80.0;

    const collapsedWidth = 70.0 + 16.0;
    const expandedWidth = 250.0 + 16.0;

    double contentLeftOffset;
    if (isSmallScreen) {
      contentLeftOffset = collapsedWidth;
    } else {
      contentLeftOffset = _isSidebarCollapsed ? collapsedWidth : expandedWidth;
    }

    // Publish the sidebar's effective width so widgets mounted above the
    // Navigator (e.g. the toast host) can dodge it. Done in a post-frame
    // callback to avoid mutating signals during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      shellLayoutSignal.setSidebarWidth(contentLeftOffset);
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          appBackHandler.invoke(context);
        },
        child: Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          body: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                left: contentLeftOffset,
                top: 0,
                right: 0,
                bottom: 0,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context),
                  child: widget.child,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: WindowTitleBar(leftOffset: contentLeftOffset),
              ),
              // Sidebar always above player; z-order handled by paint order
              Positioned(
                key: const ValueKey('sidebar'),
                left: 0,
                top: 0,
                bottom: 0,
                child: Sidebar(
                  isCollapsed: _isSidebarCollapsed,
                  onToggle: _toggleSidebar,
                ),
              ),
              // Player is a stable widget keyed by `_playerKey`. Lifted out
              // of the previous SignalBuilder so it isn't rebuilt on every sidebar
              // layout change or signal write from this shell.
              MorphingPlayer(
                key: _playerKey,
                leftOffset: contentLeftOffset,
                bottomOffset: 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
