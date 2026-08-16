// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
/// Stub used on platforms where `dart:io` is unavailable (i.e. the web).
/// The conditional import in `mpris_helper.dart` selects this file unless
/// `dart.library.io` is available, in which case `mpris_helper_native.dart`
/// is loaded instead — that file then guards the actual registration on
/// `Platform.isLinux` to avoid attempting D-Bus on Android/iOS.
///
/// Public so the conditional import in `mpris_helper.dart` can resolve it.
void registerMprisPlatformImpl() {
  // No-op: the platform's native media-control surface is handled by
  // audio_service's built-in plugin platform.
}
