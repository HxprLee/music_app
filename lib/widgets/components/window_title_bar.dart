// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:inspire_blur/inspire_blur.dart';
import '../../signals/audio_signal.dart';
import '../../signals/search_signal.dart';
import '../../router/routes.dart';
import '../../widgets/header/desktop/desktop_header_bar.dart';
import '../../widgets/header/mobile/mobile_header_bar.dart';

class WindowTitleBar extends StatefulWidget {
  final double leftOffset;
  const WindowTitleBar({super.key, this.leftOffset = 0});

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: searchSignal.searchQuery.value,
    );

    // Sync controller with signal
    effect(() {
      final query = searchSignal.searchQuery.value;
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  String? _lastFocusedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture route changes safely (can't access GoRouterState in initState).
    final route = GoRouterState.of(context).uri.toString();
    if (route != _lastFocusedRoute) {
      _lastFocusedRoute = route;
      if (route == AppRoutes.search) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DesktopHeaderBar.current?.focusSearch();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    return SignalBuilder(
      builder: (context) {
        final expansion = audioSignal.playerExpansion.value;
        final hideContentOpacity = (1 - expansion * 2).clamp(0.0, 1.0);
        final showBlur = audioSignal.headerShowBlur.value && expansion < 0.1;

        return IgnorePointer(
          ignoring: expansion > 0.5,
          child: GestureDetector(
            onPanStart: isDesktop
                ? (details) {
                    windowManager.startDragging();
                  }
                : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Inspire.backdropBlur(
                  config: InspireBlurConfig.topToBottom(sigma: 20, extent: 1.0),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: showBlur
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.9),
                              Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.0),
                            ],
                          )
                        : null,
                  ),
                  child: isDesktop
                      ? DesktopHeaderBar(
                          leftOffset: widget.leftOffset,
                          hideContentOpacity: hideContentOpacity,
                          expansion: expansion,
                          searchController: _searchController,
                        )
                      : MobileHeaderBar(
                          leftOffset: widget.leftOffset,
                          hideContentOpacity: hideContentOpacity,
                          expansion: expansion,
                          searchController: _searchController,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
