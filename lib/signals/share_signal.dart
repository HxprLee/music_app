// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:signals/signals_flutter.dart';

class ShareSignal {
  final incomingUrl = signal<String?>(null);
}

final shareSignal = ShareSignal();