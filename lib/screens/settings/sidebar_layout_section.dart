// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../signals/audio_signal.dart';
import '../../signals/settings_signal.dart';
import '../../theme/app_theme_tokens.dart';
import '../../widgets/components/settings_section.dart';
import '../../widgets/components/sliver_page_header.dart';

class SidebarLayoutSection extends StatelessWidget {
  const SidebarLayoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverPageHeader(
            title: 'Sidebar Items',
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
                      child: SignalBuilder(builder: (context) {
                        final pinnedItems = settingsSignal.pinnedSidebarItems.value;
                        final allItems = [
                          {'id': 'albums', 'label': 'Albums', 'icon': Icons.album},
                          {'id': 'songs', 'label': 'Songs', 'icon': Icons.audiotrack},
                          {'id': 'playlists', 'label': 'Playlists', 'icon': Icons.list},
                          {'id': 'folders', 'label': 'Folders', 'icon': Icons.folder},
                          {'id': 'artists', 'label': 'Artists', 'icon': Icons.person},
                          {'id': 'downloaded', 'label': 'Downloaded', 'icon': Icons.download_done},
                        ];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Toggle items that appear in your sidebar library section.',
                                style: TextStyle(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.54),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SettingsDivider(indent: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: allItems.length,
                              separatorBuilder: (context, index) =>
                                  const SettingsDivider(indent: 16),
                              itemBuilder: (context, index) {
                                final item = allItems[index];
                                final itemId = item['id'] as String;
                                final isPinned = pinnedItems.contains(itemId);

                                return CheckboxListTile(
                                  value: isPinned,
                                  onChanged: (value) =>
                                      settingsSignal.togglePinnedItem(itemId),
                                  title: Text(
                                    item['label'] as String,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  secondary: Icon(
                                    item['icon'] as IconData,
                                    color: isPinned
                                        ? context.colorScheme.secondary
                                        : context.colorScheme.onSurface
                                            .withValues(alpha: 0.38),
                                    size: 20,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SignalBuilder(builder: (context) =>
                        SizedBox(height: audioSignal.reservedHeight.value)),
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
