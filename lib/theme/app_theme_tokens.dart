// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

/// Ergonomic access to the app's theme tokens from any [BuildContext].
///
/// Widgets should read theme colors through this extension instead of
/// reaching for `Theme.of(context).extension<AppThemeExtension>()!` chains
/// or hand-rolling `colorScheme.secondary.withValues(alpha: ...)` blocks.
extension AppThemeTokens on BuildContext {
  /// The semantic tokens for the current theme.
  AppThemeExtension get tokens =>
      Theme.of(this).extension<AppThemeExtension>()!;

  /// The active [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The accent color with the given [opacity] applied.
  ///
  /// Replaces the very common
  /// `Theme.of(context).colorScheme.secondary.withValues(alpha: x)` pattern.
  Color accentOf([double opacity = 1.0]) =>
      colorScheme.secondary.withValues(alpha: opacity);

  /// The on-surface color with the given [opacity] applied.
  Color onSurfaceOf([double opacity = 1.0]) =>
      colorScheme.onSurface.withValues(alpha: opacity);

  /// Tinted accent border color (e.g. for card outlines).
  Color accentBorder([double opacity = 0.15]) => accentOf(opacity);

  /// Tinted on-surface divider color.
  Color subtleDivider([double opacity = 0.05]) => onSurfaceOf(opacity);

  /// Tinted on-surface icon color for muted/disabled states.
  Color mutedIcon([double opacity = 0.3]) => onSurfaceOf(opacity);

  /// Whether the current theme is a Material 3 / dynamic-color scheme.
  bool get isMaterial3 => tokens.scheme == AppColorScheme.material3;
}
