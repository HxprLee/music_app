// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../signals/settings_signal.dart';
import '../../theme/app_theme_tokens.dart';
import '../../widgets/components/settings_section.dart';
import '../../widgets/components/sliver_page_header.dart';

class DiscordPresenceSection extends StatelessWidget {
  const DiscordPresenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverPageHeader(
            title: 'Discord Presence',
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
                          SignalBuilder(builder: (context) => SettingsTile(
                            title: 'Listen on YouTube Button',
                            subtitle: 'Show "Listen on YouTube" button in Discord status',
                            showLeading: false,
                            trailing: Switch(
                              value: settingsSignal.enableDiscordListenButton.value,
                              onChanged: settingsSignal.enableDiscordRpc.value
                                  ? (value) => settingsSignal.updateDiscordListenButton(value)
                                  : null,
                              activeThumbColor: context.colorScheme.secondary,
                            ),
                          )),
                          const SettingsDivider(indent: 16),
                          SignalBuilder(builder: (context) => SettingsTile(
                            title: 'Open Project Button',
                            subtitle: 'Show "Open Project" button in Discord status',
                            showLeading: false,
                            trailing: Switch(
                              value: settingsSignal.enableDiscordProjectLink.value,
                              onChanged: settingsSignal.enableDiscordRpc.value
                                  ? (value) => settingsSignal.updateDiscordProjectLink(value)
                                  : null,
                              activeThumbColor: context.colorScheme.secondary,
                            ),
                          )),
                        ],
                      ),
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
