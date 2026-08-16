// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'dart:io';
import 'package:flutter/foundation.dart';

bool get isDesktop =>
    !kIsWeb &&
    (Platform.isLinux && !Platform.isAndroid || Platform.isWindows || Platform.isMacOS);

bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
