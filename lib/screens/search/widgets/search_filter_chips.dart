// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterOption<T> {
  final String label;
  final T filter;
  final FaIconData icon;

  const FilterOption(this.label, this.filter, this.icon);
}

class SearchFilterChips<T> extends StatelessWidget {
  final List<FilterOption<T>> options;
  final T currentFilter;
  final ValueChanged<T> onFilterChanged;

  const SearchFilterChips({
    super.key,
    required this.options,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = options[index];
          final isSelected = opt.filter == currentFilter;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: FaIcon(
              opt.icon,
              size: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.secondary,
            ),
            label: Text(opt.label),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.secondary,
            ),
            selectedColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => onFilterChanged(opt.filter),
          );
        },
      ),
    );
  }
}
