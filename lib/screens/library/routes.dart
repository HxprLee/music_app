// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/transitions.dart';
import '../library_screen.dart';
import '../albums_screen.dart';
import '../album_detail_screen.dart';
import '../artists_screen.dart';
import '../artist_detail_screen.dart';
import '../playlists_screen.dart';
import '../playlist_screen.dart';
import '../file_explorer_screen.dart';
import '../recently_played_screen.dart';
import '../recently_added_screen.dart';
import '../most_played_screen.dart';
import '../../widgets/songs_list_content.dart';
import '../../signals/audio_signal.dart';

List<GoRoute> get libraryRoutes => [
  GoRoute(
    path: AppRoutes.songs,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const SongsListContent()),
  ),
  GoRoute(
    path: AppRoutes.library,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const LibraryScreen()),
  ),
  GoRoute(
    path: AppRoutes.recentlyPlayed,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const RecentlyPlayedScreen()),
  ),
  GoRoute(
    path: AppRoutes.mostPlayed,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const MostPlayedScreen()),
  ),
  GoRoute(
    path: AppRoutes.recentlyAdded,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const RecentlyAddedScreen()),
  ),
  GoRoute(
    path: AppRoutes.explorer,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const FileExplorerScreen()),
  ),
  GoRoute(
    path: '${AppRoutes.explorer}/:path',
    pageBuilder: (context, state) {
      final path = state.pathParameters['path'] ?? '';
      return buildPageWithTransition(
        state,
        FileExplorerScreen(initialPath: path),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.playlists,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const PlaylistsScreen()),
  ),
  GoRoute(
    path: '/playlist/:id',
    redirect: (context, state) {
      final playlistId = state.pathParameters['id'];
      if (playlistId == null) return AppRoutes.library;
      final playlists = audioSignal.playlists.value;
      final index = playlists.indexWhere((p) => p.id == playlistId);
      if (index == -1) return AppRoutes.library;
      return null;
    },
    pageBuilder: (context, state) {
      final playlistId = state.pathParameters['id']!;
      final playlists = audioSignal.playlists.value;
      final index = playlists.indexWhere((p) => p.id == playlistId);
      return buildPageWithTransition(
        state,
        PlaylistScreen(playlist: playlists[index]),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.artists,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const ArtistsScreen()),
  ),
  GoRoute(
    path: '${AppRoutes.artists}/:name',
    pageBuilder: (context, state) {
      final name = state.pathParameters['name'] ?? '';
      return buildPageWithTransition(
        state,
        ArtistDetailScreen(artistName: name),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.albums,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const AlbumsScreen()),
  ),
  GoRoute(
    path: '${AppRoutes.albums}/:artist/:name',
    pageBuilder: (context, state) {
      final artist = state.pathParameters['artist'] ?? '';
      final name = state.pathParameters['name'] ?? '';
      return buildPageWithTransition(
        state,
        AlbumDetailScreen(artistName: artist, albumName: name),
      );
    },
  ),
];
