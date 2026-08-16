// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:signals/signals_flutter.dart';

/// Tags the open-modal-overlay state of the app. Consumed by the central
/// back-handler so the system back button closes the topmost overlay instead
/// of popping the route or backgrounding the app.
enum ActiveOverlay {
  none,

  // Drawer (mobile shell only).
  drawer,

  // Bottom sheets.
  songActions,
  queue,
  lyrics,

  // Modal dialogs.
  sleepTimer,
  playbackSpeed,
  playlistPicker,
  songInfo,
  editMetadata,
  createPlaylist,
  managePlaylists,
  cacheConfirm,
  clearHistoryConfirm,
  resetDirectoryConfirm,
  clearMissingConfirm,
  forceScanConfirm,
  ytLoginInstructions,
  integrationsConnect,

  // File explorer.
  folderMenu,

  // Generic fallback for callers that don't tag explicitly.
  unknown,
}

/// Lightweight registry of currently-open modal overlays.
///
/// The signals are mutable from anywhere; modal openers call [push] when
/// they show and the dismissing widget calls [pop] when it closes. The
/// central back-handler ([AppBackHandler]) consults [activeModalSheet] and
/// [isDrawerOpen] to decide whether to consume the back press itself.
class OverlaySignal {
  /// True when the Scaffold's drawer is open. Driven by the mobile shell.
  final Signal<bool> isDrawerOpen = signal(false);

  /// Topmost active overlay. `none` means nothing modal is open.
  final Signal<ActiveOverlay> activeModalSheet =
      signal(ActiveOverlay.none);

  void pushDrawer() {
    isDrawerOpen.value = true;
  }

  void popDrawer() {
    isDrawerOpen.value = false;
  }

  void push(ActiveOverlay overlay) {
    activeModalSheet.value = overlay;
  }

  void pop(ActiveOverlay overlay) {
    if (activeModalSheet.value == overlay) {
      activeModalSheet.value = ActiveOverlay.none;
    }
  }

  /// Reset to the closed state. Used by the back-handler after it dismisses
  /// a top-level overlay so stale tags don't leak across sessions.
  void reset() {
    isDrawerOpen.value = false;
    activeModalSheet.value = ActiveOverlay.none;
  }
}

final OverlaySignal overlaySignal = OverlaySignal();