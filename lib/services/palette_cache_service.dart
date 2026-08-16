// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaletteCacheService {
  static const String _keyPrefix = 'palette_cache_';

  static Future<Map<String, Color?>?> getPalette(String songPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = songPath.hashCode.abs().toString();
      final key = '$_keyPrefix$hash';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return {
        'dominant': _colorFromHex(map['dominant']),
        'muted': _colorFromHex(map['muted']),
        'seed': _colorFromHex(map['seed']),
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> savePalette(String songPath, Color? dominant, Color? muted, Color? seed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = songPath.hashCode.abs().toString();
      final key = '$_keyPrefix$hash';
      
      final map = {
        'dominant': _colorToHex(dominant),
        'muted': _colorToHex(muted),
        'seed': _colorToHex(seed),
      };
      await prefs.setString(key, jsonEncode(map));
    } catch (e) {
      // Ignore
    }
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return color.value.toRadixString(16).padLeft(8, '0');
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}