// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/transitions.dart';
import '../settings_screen.dart';
import 'customization_screen.dart';
import 'playback_section.dart';
import 'library_section.dart';
import 'about_section.dart';
import 'actions_layout_section.dart';
import 'player_bar_layout_section.dart';
import 'lyrics_appearance_section.dart';
import 'sidebar_layout_section.dart';
import 'discord_presence_section.dart';
import 'cache_management_screen.dart';
import 'yt_login_webview_screen.dart';
import 'integrations_section.dart';

List<GoRoute> get settingsRoutes => [
  GoRoute(
    path: AppRoutes.settings,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const SettingsScreen()),
  ),
  GoRoute(
    path: AppRoutes.settingsCustomization,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const CustomizationScreen()),
  ),
  GoRoute(
    path: AppRoutes.settingsCustomizationActionsLayout,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const ActionsLayoutSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsCustomizationPlayerLayout,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const PlayerBarLayoutSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsCustomizationLyricsLayout,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const LyricsAppearanceSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsCustomizationSidebarLayout,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const SidebarLayoutSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsPlayback,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const PlaybackSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsLibrary,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const LibrarySection()),
  ),
  GoRoute(
    path: AppRoutes.settingsLibraryManageCache,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const CacheManagementScreen()),
  ),
  GoRoute(
    path: AppRoutes.settingsIntegrations,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const IntegrationsSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsIntegrationsDiscordPresence,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const DiscordPresenceSection()),
  ),
  GoRoute(
    path: AppRoutes.settingsIntegrationsYoutubeLogin,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const YtLoginWebViewScreen()),
  ),
  GoRoute(
    path: AppRoutes.settingsAbout,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const AboutSection()),
  ),
];
