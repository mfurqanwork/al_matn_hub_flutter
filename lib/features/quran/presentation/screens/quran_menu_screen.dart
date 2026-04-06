import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/quran_menu_provider.dart';
import '../providers/quran_reader_notifier.dart';
import '../../../../core/utils/quran_helpers.dart';
import '../widgets/surah_list_tile.dart';
import '../../../../core/widgets/continue_reading_banner.dart';

class QuranMenuScreen extends ConsumerWidget {
  const QuranMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readerState = ref.watch(quranReaderNotifierProvider);
    final lastReadPage = readerState.value?.lastReadPage ?? 1;
    final lastReadLabel = pageOverlayLabel(lastReadPage);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/logo.png', width: 28, height: 28),
              const SizedBox(width: 8),
              Text(
                'Quran',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ContinueReadingBanner(
                title: 'Continue Reading',
                subtitle: '$lastReadLabel · Page $lastReadPage',
                icon: 'assets/icons/ic_quran.png',
                onTap: () => _openReader(context, lastReadPage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Auto Track Last Read',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: readerState.value?.autoTracingEnabled ?? true,
                      activeColor: const Color(0xFF007A33),
                      onChanged: (val) => ref
                          .read(quranReaderNotifierProvider.notifier)
                          .toggleAutoTracing(),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Surahs'),
                Tab(text: 'Juz'),
              ],
            ),
            Expanded(
              child: TabBarView(
                clipBehavior: Clip.hardEdge,
                children: [
                  _SurahTabBody(
                    onSurahSelected: (page) => _openReader(context, page),
                  ),
                  _JuzGrid(onJuzSelected: (page) => _openReader(context, page)),
                ],
              ),
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

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: juzList.length,
        itemBuilder: (context, index) {
          final juz = juzList[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF007A33).withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007A33).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Centered minimal text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Juz ${juz.number}',
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ripple effect interaction layer
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: () => onJuzSelected(juz.startPage)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Surah...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Image.asset(
                  'assets/icons/ic_search.png',
                  width: 24,
                  height: 24,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
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
