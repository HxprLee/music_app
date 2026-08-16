// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/transitions.dart';
import 'search_screen.dart';
import 'search_result_screen.dart';
import 'see_more_screen.dart';
import 'mood_screen.dart';

List<GoRoute> get searchRoutes => [
  GoRoute(
    path: AppRoutes.search,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const SearchScreen()),
  ),
  GoRoute(
    path: AppRoutes.searchResult,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const SearchResultScreen()),
  ),
  GoRoute(
    path: AppRoutes.seeMore,
    redirect: (context, state) {
      // The see-more screen requires a sectionKey in `extra` to render.
      // Without it, fall back to the search screen rather than crashing.
      final extra = state.extra;
      if (extra is! Map<String, dynamic>) return AppRoutes.search;
      final key = extra['sectionKey'];
      if (key is! String || key.isEmpty) return AppRoutes.search;
      return null;
    },
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      return buildPageWithTransition(
        state,
        SeeMoreScreen(
          sectionKey: extra['sectionKey'] as String,
          title: extra['title'] as String? ?? 'More',
        ),
      );
    },
  ),
  GoRoute(
    path: '${AppRoutes.mood}/:params',
    pageBuilder: (context, state) {
      final params = Uri.decodeComponent(state.pathParameters['params'] ?? '');
      final title = state.extra as String? ?? 'Mood';
      return buildPageWithTransition(
        state,
        MoodScreen(title: title, params: params),
      );
    },
  ),
];
