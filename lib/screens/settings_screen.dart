// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signals/signals_flutter.dart';
import '../router/routes.dart';
import '../signals/audio_signal.dart';
import '../utils/navigation.dart';
import '../widgets/components/settings_section.dart';
import '../widgets/components/sliver_page_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverPageHeader(
            title: 'Settings',
            maxWidth: 600,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    SettingsSection(
                      child: Column(
                        children: [
                          SettingsTile(
                            icon: FontAwesomeIcons.sliders,
                            title: 'Customization',
                            subtitle: 'Themes, layouts, and visual effects',
                            onTap: () =>
                                navigatePush(context, AppRoutes.settingsCustomization),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: FontAwesomeIcons.play,
                            title: 'Playback',
                            subtitle:
                                'Controls, gestures, and background behavior',
                            onTap: () => navigatePush(context, AppRoutes.settingsPlayback),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: FontAwesomeIcons.music,
                            title: 'Library',
                            subtitle: 'Manage music folders and indexing',
                            onTap: () => navigatePush(context, AppRoutes.settingsLibrary),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: FontAwesomeIcons.plug,
                            title: 'Integrations',
                            subtitle: 'Discord, YouTube Music, and Last.fm',
                            onTap: () => navigatePush(context, AppRoutes.settingsIntegrations),
                          ),
                          const SettingsDivider(),
                          SettingsTile(
                            icon: FontAwesomeIcons.circleInfo,
                            title: 'About',
                            subtitle:
                                'Version information and developer links',
                            onTap: () => navigatePush(context, AppRoutes.settingsAbout),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SignalBuilder(builder: (context) =>
                          SizedBox(height: audioSignal.reservedHeight.value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
