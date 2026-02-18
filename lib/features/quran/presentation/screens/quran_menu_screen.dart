import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../providers/quran_menu_provider.dart';
import '../widgets/surah_list_tile.dart';

class QuranMenuScreen extends ConsumerWidget {
  const QuranMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 28, height: 28),
              const SizedBox(width: 8),
              Text(
                'Holy Quran',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Juz'),
              Tab(text: 'Surahs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JuzGrid(onJuzSelected: (page) => _openReader(context, page)),
            _SurahTabBody(
              onSurahSelected: (page) => _openReader(context, page),
            ),
          ],
        ),
      ),
    );
  }

  void _openReader(BuildContext context, int startPage) {
    context.go('/quran/reader?page=$startPage');
  }
}

// ── Juz grid ─────────────────────────────────────────────────────────────────

class _JuzGrid extends ConsumerWidget {
  const _JuzGrid({required this.onJuzSelected});

  final void Function(int startPage) onJuzSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzList = ref.watch(juzListProvider);
    final theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        return InkWell(
          onTap: () => onJuzSelected(juz.startPage),
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${juz.number}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Juz',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Surah tab (search + list) ─────────────────────────────────────────────────

class _SurahTabBody extends ConsumerWidget {
  const _SurahTabBody({required this.onSurahSelected});

  final void Function(int startPage) onSurahSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredSurahListProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search surah...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  'assets/icons/ic_search.svg',
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (q) =>
                ref.read(surahSearchProvider.notifier).setQuery(q),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final surah = filtered[index];
              return SurahListTile(
                surah: surah,
                onTap: () => onSurahSelected(surah.startPage),
              );
            },
          ),
        ),
      ],
    );
  }
}
