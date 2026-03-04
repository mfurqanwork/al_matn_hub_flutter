import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../providers/quran_menu_provider.dart';
import '../providers/quran_reader_notifier.dart';
import '../../../../core/utils/quran_helpers.dart';
import '../widgets/surah_list_tile.dart';

class QuranMenuScreen extends ConsumerWidget {
  const QuranMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readerState = ref.watch(quranReaderNotifierProvider);
    final lastReadPage = readerState.value?.currentPage ?? 1;
    final lastReadLabel = pageOverlayLabel(lastReadPage);

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
                'Quran',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: InkWell(
                onTap: () => _openReader(context, lastReadPage),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007A33).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/icons/home_bg.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/ic_quran.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Continue Reading',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$lastReadLabel · Page $lastReadPage',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  // Green accent bar on the left edge
                  Positioned(
                    left: 0,
                    top: 16,
                    bottom: 16,
                    child: Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF007A33),
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
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
                        const SizedBox(height: 4),
                        Text(
                          'Page ${juz.startPage}',
                          style: const TextStyle(
                            color: Color(0xFF007A33),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                child: SvgPicture.asset(
                  'assets/icons/ic_search.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFB8860B),
                    BlendMode.srcIn,
                  ),
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
