// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:signals/signals_flutter.dart';

/// Layout-level runtime measurements shared between the shell and any
/// overlay mounted above it (toasts, OSDs, global popups).
///
/// Lives here, not in [SettingsSignal], because the values are derived
/// from the currently-running shell's layout — they are not user
/// preferences and aren't persisted across launches.
class ShellLayoutSignal {
  /// Effective horizontal width occupied by the persistent sidebar on
  /// desktop shells. `0` on mobile shells or when the sidebar is hidden.
  ///
  /// Written by [HomeShellDesktop] whenever its sidebar's expanded width
  /// changes (toggle, drag-to-resize, screen-size breakpoints). Read by
  /// anything that needs to dodge the sidebar — currently the global toast
  /// host, which anchors toasts to the bottom of the *content* area, not
  /// the full screen.
  final Signal<double> sidebarWidth = signal<double>(0);

  void setSidebarWidth(double width) {
    sidebarWidth.value = width;
  }
}

final ShellLayoutSignal shellLayoutSignal = ShellLayoutSignal();
