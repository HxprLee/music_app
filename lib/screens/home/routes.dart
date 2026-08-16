// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/transitions.dart';
import '../home_screen.dart';

List<GoRoute> get homeRoutes => [
  GoRoute(
    path: AppRoutes.home,
    pageBuilder: (context, state) =>
        buildPageWithTransition(state, const HomeScreen()),
  ),
];
