import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../core/utils/quran_helpers.dart';
import '../providers/quran_reader_notifier.dart';

// ── Medinah Mushaf Color Palette ─────────────────────────────────────────────
const _kMushafCream = Color(0xFFFDF8F0); // warm parchment background
const _kMushafText = Color(0xFF1A1A1A); // near-black for text
const _kMushafGold = Color(0xFFB8860B); // dark golden rod
const _kMushafGoldLight = Color(0xFFD4AF37); // classic gold
const _kMushafGreen = Color(0xFF007A33); // Islamic green
const _kMushafBrown = Color(0xFF6B3A2A); // verse number color
const _kFrameBorder = Color(0xFFC9A96E); // warm gold for border frames

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key, required this.initialPage});

  final int initialPage;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  bool _didSyncInitialPage = false;
  late final PageController _externalController;

  @override
  void initState() {
    super.initState();
    _externalController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _externalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readerAsync = ref.watch(quranReaderNotifierProvider);

    return Scaffold(
      backgroundColor: _kMushafCream,
      body: readerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _kMushafGreen),
        ),
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

    final page = reader.currentPage;
    final pageData = getPageData(page);
    final firstSurah = int.parse(pageData.first['surah'].toString());
    final firstVerse = int.parse(pageData.first['start'].toString());
    final surahNameAr = getSurahNameArabic(firstSurah);
    final juzNum = getJuzNumber(firstSurah, firstVerse);

    return SafeArea(
      child: Column(
        children: [
          // ── Mushaf Header ──────────────────────────────────────────
          _MushafHeader(
            surahNameAr: surahNameAr,
            juzNum: juzNum,
            page: page,
            isBookmarked: reader.isBookmarked(page),
            onBookmarkToggle: () => ref
                .read(quranReaderNotifierProvider.notifier)
                .toggleBookmark(page),
            onHomeTap: () => context.go('/home'),
            onBookmarkListTap: () => _showBookmarkSheet(context),
          ),

          // ── QCF Page Content ──────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _kMushafCream,
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: _kFrameBorder.withAlpha(80),
                    width: 1.5,
                  ),
                ),
              ),
              child: PageviewQuran(
                controller: _externalController,
                initialPageNumber: widget.initialPage,
                onPageChanged: (p) {
                  ref.read(quranReaderNotifierProvider.notifier).updatePage(p);
                },
                theme: QcfThemeData(
                  pageBackgroundColor: _kMushafCream,
                  verseTextColor: _kMushafText,
                  verseNumberColor: _kMushafBrown,
                  basmalaColor: _kMushafText,
                  headerTextColor: _kMushafGold,
                  headerBackgroundColor: Colors.transparent,
                  horizontalPadding: 8,
                  verticalPadding: 4,
                ),
              ),
            ),
          ),

          // ── Mushaf Footer ──────────────────────────────────────────
          _MushafFooter(page: page),
        ],
      ),
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
              context.go('/quran/reader?page=$page');
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

// ── Mushaf Header (Surah name + Juz + Bookmark) ──────────────────────────────

class _MushafHeader extends StatelessWidget {
  const _MushafHeader({
    required this.surahNameAr,
    required this.juzNum,
    required this.page,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onHomeTap,
    required this.onBookmarkListTap,
  });

  final String surahNameAr;
  final int juzNum;
  final int page;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onHomeTap;
  final VoidCallback onBookmarkListTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kMushafCream,
        border: Border(
          bottom: BorderSide(color: _kFrameBorder.withAlpha(120), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Juz number (left side, matching traditional Mushaf layout)
          _OrnamentedLabel(text: 'الجزء $juzNum'),
          const Spacer(),
          // Home
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_home.svg',
              width: 22,
              colorFilter: const ColorFilter.mode(
                _kMushafGold,
                BlendMode.srcIn,
              ),
            ),
            tooltip: 'Home',
            onPressed: onHomeTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
          const SizedBox(width: 16),
          // Bookmarks List
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_bookmarks_list.svg',
              width: 22,
              colorFilter: const ColorFilter.mode(
                _kMushafGold,
                BlendMode.srcIn,
              ),
            ),
            tooltip: 'Bookmarks List',
            onPressed: onBookmarkListTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
          const SizedBox(width: 16),

          // Bookmark icon
          GestureDetector(
            onTap: onBookmarkToggle,
            child: SvgPicture.asset(
              'assets/icons/ic_bookmark.svg',
              width: 22,
              colorFilter: ColorFilter.mode(
                isBookmarked ? _kMushafGreen : _kFrameBorder.withAlpha(120),
                BlendMode.srcIn,
              ),
            ),
          ),
          const Spacer(),
          // Surah name (right side, matching traditional Mushaf layout)
          _OrnamentedLabel(text: 'سورة $surahNameAr'),
        ],
      ),
    );
  }
}

// ── Ornamented label (mimics Mushaf decorative text frames) ──────────────────

class _OrnamentedLabel extends StatelessWidget {
  const _OrnamentedLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kFrameBorder, width: 1.2),
        gradient: LinearGradient(
          colors: [
            _kMushafGoldLight.withAlpha(20),
            _kMushafGoldLight.withAlpha(40),
            _kMushafGoldLight.withAlpha(20),
          ],
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _kMushafGold,
          letterSpacing: 1.2,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ── Mushaf Footer (page number in Arabic style) ─────────────────────────────

class _MushafFooter extends StatelessWidget {
  const _MushafFooter({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _kMushafCream,
        border: Border(
          top: BorderSide(color: _kFrameBorder.withAlpha(120), width: 1.5),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kFrameBorder.withAlpha(80), width: 1),
          ),
          child: Text(
            // Arabic-style page number with decorative dashes
            '— $page —',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: _kMushafGold,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
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
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic_bookmarks_list.svg',
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      _kMushafGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Bookmarks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _kFrameBorder.withAlpha(60)),
            Expanded(
              child: bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_bookmark.svg',
                            width: 48,
                            colorFilter: ColorFilter.mode(
                              Colors.grey.shade300,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No bookmarks yet',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 56,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (_, i) {
                        final page = bookmarks[i];
                        final label = pageOverlayLabel(page);
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _kMushafGreen.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/ic_bookmark.svg',
                                width: 20,
                                colorFilter: const ColorFilter.mode(
                                  _kMushafGreen,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Page $page',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade300,
                              size: 20,
                            ),
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
