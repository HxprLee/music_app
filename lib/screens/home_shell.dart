// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'home/home_shell_mobile.dart';
import 'home/home_shell_desktop.dart';

/// Shell widget that wraps all routes with common UI elements.
/// Delegates to platform-specific implementations.
class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? HomeShellDesktop(child: child)
        : HomeShellMobile(child: child);
  }
}
