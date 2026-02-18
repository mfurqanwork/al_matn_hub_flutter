import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/quran_reader_notifier.dart';
import '../providers/quran_menu_provider.dart';

class SurahListTile extends ConsumerWidget {
  const SurahListTile({super.key, required this.surah, required this.onTap});

  final SurahInfo surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
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
