// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'mpris_helper_stub.dart'
    if (dart.library.io) 'mpris_helper_native.dart';

/// Register the audio handler with the platform's media-control surface.
///
/// - On Linux: wires up MPRIS over D-Bus so GNOME Shell, KDE Plasma,
///   `playerctl`, and other MPRIS clients can see and control playback.
/// - On Android / iOS / web: no-op (audio_service uses the platform's
///   native notification surface instead).
///
/// Must be called **before** `AudioService.init()` so the platform is
/// registered before the audio handler is built.
void registerMprisService() => registerMprisPlatformImpl();
