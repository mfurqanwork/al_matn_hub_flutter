import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/quran_helpers.dart';
import '../providers/quran_reader_notifier.dart';
import '../widgets/quran_page_widget.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key, required this.initialPage});

  final int initialPage;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late final PageController _pageController;
  bool _didSyncInitialPage = false;

  @override
  void initState() {
    super.initState();
    final viewIndex = pageToViewIndex(widget.initialPage);
    _pageController = PageController(initialPage: viewIndex);

    // Precache the initial spread (±2 pages) after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheNearby(widget.initialPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _precacheNearby(int page) {
    // Preload ±5 pages for smooth transitions
    for (int offset = -5; offset <= 5; offset++) {
      final p = page + offset;
      if (p < 1 || p > AppConstants.totalPages) continue;
      precacheImage(AssetImage(pageAssetPath(p)), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerAsync = ref.watch(quranReaderNotifierProvider);

    return Scaffold(
      // No AppBar – full-screen immersive reader
      backgroundColor: Colors.black,
      body: readerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reader) => _buildReader(context, reader),
      ),
    );
  }

  Widget _buildReader(BuildContext context, ReaderState reader) {
    if (!_didSyncInitialPage) {
      _didSyncInitialPage = true;
      if (reader.currentPage != widget.initialPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(quranReaderNotifierProvider.notifier)
              .updatePage(widget.initialPage);
        });
      }
    }

    return Stack(
      children: [
        // ── Page view ──────────────────────────────────────────────────
        GestureDetector(
          onTap: () =>
              ref.read(quranReaderNotifierProvider.notifier).toggleControls(),
          child: PageView.builder(
            controller: _pageController,
            // reverse=false: swipe RIGHT → next page (requested Mushaf behavior)
            reverse: false,
            // Enables pre-rendering of neighboring pages
            allowImplicitScrolling: true,
            itemCount: AppConstants.totalPages,
            onPageChanged: (viewIndex) {
              final realPage = viewIndexToPage(viewIndex);
              ref
                  .read(quranReaderNotifierProvider.notifier)
                  .updatePage(realPage);
              _precacheNearby(realPage);
            },
            itemBuilder: (context, viewIndex) {
              final pageNum = viewIndexToPage(viewIndex);
              return QuranPageWidget(pageNum: pageNum);
            },
          ),
        ),

        // ── Top overlay ────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          top: reader.controlsVisible ? 0 : -100,
          left: 0,
          right: 0,
          child: _TopBar(
            page: reader.currentPage,
            isBookmarked: reader.isBookmarked(reader.currentPage),
            onBookmarkToggle: () => ref
                .read(quranReaderNotifierProvider.notifier)
                .toggleBookmark(reader.currentPage),
            onMenuTap: () => context.go('/quran'),
            onBookmarkListTap: () => _showBookmarkSheet(context),
          ),
        ),

        // ── Bottom overlay ─────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          bottom: reader.controlsVisible ? 0 : -80,
          left: 0,
          right: 0,
          child: _BottomBar(page: reader.currentPage),
        ),
      ],
    );
  }

  void _showBookmarkSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final bookmarks = ref.watch(
            quranReaderNotifierProvider.select(
              (value) => value.value?.bookmarks ?? const <int>[],
            ),
          );

          return _BookmarkSheet(
            bookmarks: bookmarks,
            onPageSelected: (page) {
              Navigator.pop(ctx);
              final viewIndex = pageToViewIndex(page);
              _pageController.jumpToPage(viewIndex);
            },
            onRemove: (page) => ref
                .read(quranReaderNotifierProvider.notifier)
                .toggleBookmark(page),
          );
        },
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.page,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onMenuTap,
    required this.onBookmarkListTap,
  });

  final int page;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onMenuTap;
  final VoidCallback onBookmarkListTap;

  @override
  Widget build(BuildContext context) {
    final label = pageOverlayLabel(page);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 4,
        left: 8,
        right: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Menu
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_home.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFF007A33),
                BlendMode.srcIn,
              ),
              width: 24,
            ),
            tooltip: 'Home',
            onPressed: () => context.go('/home'),
          ),
          // Bookmark list
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_bookmarks_list.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFF007A33),
                BlendMode.srcIn,
              ),
              width: 24,
            ),
            tooltip: 'Bookmarks',
            onPressed: onBookmarkListTap,
          ),
          const Spacer(),
          // Surah / Juz label
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Amiri',
              fontSize: 14,
              shadows: [Shadow(blurRadius: 4)],
            ),
          ),
          const Spacer(),
          // Bookmark toggle
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_bookmark.svg',
              colorFilter: ColorFilter.mode(
                isBookmarked ? const Color(0xFF007A33) : Colors.white,
                BlendMode.srcIn,
              ),
              width: 24,
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            onPressed: onBookmarkToggle,
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 8,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: Center(
        child: Text(
          'Page $page / ${AppConstants.totalPages}',
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Amiri',
            fontSize: 13,
            shadows: [Shadow(blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}

// ── Bookmark bottom sheet ─────────────────────────────────────────────────────

class _BookmarkSheet extends StatelessWidget {
  const _BookmarkSheet({
    required this.bookmarks,
    required this.onPageSelected,
    required this.onRemove,
  });

  final List<int> bookmarks;
  final void Function(int page) onPageSelected;
  final void Function(int page) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Bookmarks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: bookmarks.isEmpty
                  ? const Center(
                      child: Text(
                        'No bookmarks yet',
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: bookmarks.length,
                      itemBuilder: (_, i) {
                        final page = bookmarks[i];
                        final label = pageOverlayLabel(page);
                        return ListTile(
                          leading: SvgPicture.asset(
                            'assets/icons/ic_bookmark.svg',
                            width: 24,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF007A33),
                              BlendMode.srcIn,
                            ),
                          ),
                          title: Text(
                            label,
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          subtitle: Text('Page $page'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => onRemove(page),
                          ),
                          onTap: () => onPageSelected(page),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
