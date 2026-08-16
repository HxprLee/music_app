// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/transitions.dart';
import '../youtube_music_screen.dart';
import '../yt_album_screen.dart';
import '../yt_artist_screen.dart';
import '../yt_playlist_screen.dart';
import '../search/yt_library_screen.dart';

List<GoRoute> get youtubeRoutes => [
  GoRoute(
    path: AppRoutes.youtube,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const YoutubeMusicScreen()),
  ),
  GoRoute(
    path: '${AppRoutes.youtube}/album/:id',
    pageBuilder: (context, state) {
      final id = Uri.decodeComponent(state.pathParameters['id'] ?? '');
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return buildPageWithTransition(state, YtAlbumScreen(
        browseId: id,
        title: extra['title'] ?? '',
        thumbnailUrl: extra['thumbnailUrl'] ?? '',
      ));
    },
  ),
  GoRoute(
    path: '${AppRoutes.youtube}/artist/:id',
    pageBuilder: (context, state) {
      final id = Uri.decodeComponent(state.pathParameters['id'] ?? '');
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return buildPageWithTransition(state, YtArtistScreen(
        channelId: id,
        name: extra['name'] ?? '',
        thumbnailUrl: extra['thumbnailUrl'] ?? '',
      ));
    },
  ),
  GoRoute(
    path: '${AppRoutes.youtube}/playlist/:id',
    pageBuilder: (context, state) {
      final id = Uri.decodeComponent(state.pathParameters['id'] ?? '');
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return buildPageWithTransition(state, YtPlaylistScreen(
        playlistId: id,
        title: extra['title'] ?? '',
        thumbnailUrl: extra['thumbnailUrl'] ?? '',
      ));
    },
  ),
  GoRoute(
    path: AppRoutes.ytLibraryPlaylists,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const YtLibraryScreen(type: YTLibraryType.playlists)),
  ),
  GoRoute(
    path: AppRoutes.ytLibraryAlbums,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const YtLibraryScreen(type: YTLibraryType.albums)),
  ),
  GoRoute(
    path: AppRoutes.ytLibraryArtists,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const YtLibraryScreen(type: YTLibraryType.artists)),
  ),
];
