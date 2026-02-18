import 'package:flutter/material.dart';

import '../providers/quran_menu_provider.dart';

/// A single Surah row in the menu list.
class SurahListTile extends StatelessWidget {
  const SurahListTile({super.key, required this.surah, required this.onTap});

  final SurahInfo surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      // Surah number badge on the trailing side (LTR position = leading in RTL)
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.secondaryContainer,
        ),
        alignment: Alignment.center,
        child: Text(
          '${surah.number}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        surah.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${surah.verseCount} verses · p ${surah.startPage}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          fontFamily: 'Amiri',
        ),
      ),
    );
  }
}
