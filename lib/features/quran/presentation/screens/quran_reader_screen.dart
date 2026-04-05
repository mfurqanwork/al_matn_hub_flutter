import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/utils/quran_helpers.dart';
import '../providers/quran_reader_notifier.dart';

// ── Medinah Mushaf Color Palette ─────────────────────────────────────────────
const _kMushafText = Color(0xFF1A1A1A); // near-black for text
const _kMushafGold = Color.fromARGB(255, 152, 112, 12); // dark golden rod
const _kMushafGreen = Color(0xFF007A33); // Islamic green
const _kMushafBrown = Color(0xFF6B3A2A); // verse number color

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final readerAsync = ref.watch(quranReaderNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
    final pageData = quran.getPageData(page);
    final firstSurah = int.parse(pageData.first['surah'].toString());
    final firstVerse = int.parse(pageData.first['start'].toString());
    final surahNameAr = quran.getSurahNameArabic(firstSurah);
    final juzNum = quran.getJuzNumber(firstSurah, firstVerse);
    final juzNameAr = getJuzNameArabic(juzNum);

    // Dynamically adjust heights based on screen size to prevent overlap
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicVerseHeight = (screenHeight / 850 * 1.9).clamp(1.5, 1.9);
    final dynamicVerseNumberHeight = (dynamicVerseHeight * 0.6).clamp(1.1, 1.3);

    return SafeArea(
      child: Column(
        children: [
          // ── Mushaf Header ──────────────────────────────────────────
          _MushafHeader(
            surahNameAr: surahNameAr,
            juzNameAr: juzNameAr,
            page: page,
            isBookmarked: reader.isBookmarked(page),
            onBookmarkToggle: () => ref
                .read(quranReaderNotifierProvider.notifier)
                .toggleBookmark(page),
            onHomeTap: () => context.go('/home'),
            onBookmarkListTap: () => _showActionSheet(context),
          ),

          // ── QCF Page Content ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 2),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _showActionSheet(context),
                child: PageviewQuran(
                  controller: _externalController,
                  initialPageNumber: widget.initialPage,
                  onPageChanged: (p) {
                    ref
                        .read(quranReaderNotifierProvider.notifier)
                        .updatePage(p);
                  },
                  theme: QcfThemeData(
                    pageBackgroundColor: Colors.white,
                    verseTextColor: _kMushafText,
                    verseNumberColor: _kMushafBrown,
                    basmalaColor: _kMushafText,
                    headerTextColor: _kMushafText,
                    headerBackgroundColor: Colors.white,
                    horizontalPadding: 12,
                    verticalPadding: 0,
                    verseHeight: dynamicVerseHeight,
                    verseNumberHeight: dynamicVerseNumberHeight,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                  ),
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

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final page =
                ref.watch(quranReaderNotifierProvider).value?.currentPage ??
                widget.initialPage;
            final isBookmarked =
                ref
                    .watch(quranReaderNotifierProvider)
                    .value
                    ?.isBookmarked(page) ??
                false;
            final bookmarks = ref.watch(
              quranReaderNotifierProvider.select(
                (v) => v.value?.bookmarks ?? <int>[],
              ),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Bookmarks Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                          child: Text(
                            'Bookmarks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _kMushafBrown,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
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
                                          Colors.grey.shade200,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No bookmarks yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: bookmarks.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    indent: 56,
                                    color: Colors.grey.shade100,
                                  ),
                                  itemBuilder: (ctx, i) {
                                    final bPage = bookmarks[i];
                                    final label = pageOverlayLabel(bPage);
                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      leading: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _kMushafGold.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/ic_bookmark.svg',
                                            width: 14,
                                            colorFilter: const ColorFilter.mode(
                                              _kMushafGold,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Page $bPage',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red.shade300,
                                          size: 18,
                                        ),
                                        onPressed: () => ref
                                            .read(
                                              quranReaderNotifierProvider
                                                  .notifier,
                                            )
                                            .toggleBookmark(bPage),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        context.go('/quran/reader?page=$bPage');
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionItem(
                          icon: 'assets/icons/ic_home.svg',
                          label: 'Home',
                          onTap: () {
                            Navigator.pop(ctx);
                            context.go('/home');
                          },
                        ),
                        _buildActionItem(
                          icon: 'assets/icons/ic_bookmark.svg',
                          label: isBookmarked ? 'Remove' : 'Bookmark',
                          color: isBookmarked ? _kMushafGreen : _kMushafGold,
                          onTap: () {
                            ref
                                .read(quranReaderNotifierProvider.notifier)
                                .toggleBookmark(page);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? _kMushafGold).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                width: 24,
                colorFilter: ColorFilter.mode(
                  color ?? _kMushafGold,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _kMushafText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MushafHeader extends StatelessWidget {
  const _MushafHeader({
    required this.surahNameAr,
    required this.juzNameAr,
    required this.page,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onHomeTap,
    required this.onBookmarkListTap,
  });

  final String surahNameAr;
  final String juzNameAr;
  final int page;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onHomeTap;
  final VoidCallback onBookmarkListTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/icons/quran_header_page.webp',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        'سُورَةُ $surahNameAr',
                        key: ValueKey(surahNameAr),
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kMushafText,
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        juzNameAr,
                        key: ValueKey(juzNameAr),
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kMushafText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MushafFooter extends StatelessWidget {
  const _MushafFooter({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/icons/quran_footer_page.webp',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  toArabicNumber(page),
                  key: ValueKey(page),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    color: _kMushafText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
