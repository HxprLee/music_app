// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
/// Typed route path constants used across the codebase.
/// Replace all string literal route paths with these constants.
abstract class AppRoutes {
  // Home
  static const String home = '/';

  // Library
  static const String songs = '/songs';
  static const String library = '/library';
  static const String explorer = '/explorer';
  static const String playlists = '/playlists';
  static const String playlist = '/playlist';
  static const String artists = '/artists';
  static const String albums = '/albums';
  static const String recentlyPlayed = '/recently-played';
  static const String recentlyAdded = '/recently-added';
  static const String mostPlayed = '/most-played';

  // Search
  static const String search = '/search';
  static const String searchResult = '/search-result';
  static const String seeMore = '/see-more';
  static const String mood = '/mood';

  // YouTube Music
  static const String youtube = '/youtube';
  static const String ytLibraryPlaylists = '/yt-library/playlists';
  static const String ytLibraryAlbums = '/yt-library/albums';
  static const String ytLibraryArtists = '/yt-library/artists';
  static const String ytPlaylistLM = '/youtube/playlist/LM';

  // Settings
  static const String settings = '/settings';
  static const String settingsCustomization = '/settings/customization';
  static const String settingsPlayback = '/settings/playback';
  static const String settingsLibrary = '/settings/library';
  static const String settingsIntegrations = '/settings/integrations';
  static const String settingsAbout = '/settings/about';
  static const String settingsCustomizationActionsLayout =
      '/settings/customization/actions-layout';
  static const String settingsCustomizationPlayerLayout =
      '/settings/customization/player-layout';
  static const String settingsCustomizationLyricsLayout =
      '/settings/customization/lyrics-layout';
  static const String settingsCustomizationSidebarLayout =
      '/settings/customization/sidebar-layout';
  static const String settingsIntegrationsDiscordPresence =
      '/settings/integrations/discord-presence';
  static const String settingsLibraryManageCache =
      '/settings/library/manage_cache';
  static const String settingsIntegrationsYoutubeLogin =
      '/settings/integrations/youtube-login';
}
