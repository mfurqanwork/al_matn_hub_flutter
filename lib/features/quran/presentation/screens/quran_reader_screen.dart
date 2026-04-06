import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/utils/quran_helpers.dart';
import '../providers/quran_reader_notifier.dart';

// ── Medinah Mushaf Color Palette ─────────────────────────────────────────────
const _kMushafText = Color(0xFF1A1A1A); // near-black for text
const _kMushafGreen = Color(0xFF007A33); // Islamic green

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

    return readerAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _kMushafGreen)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (reader) => _buildReader(context, reader),
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
    final isBookmarked = reader.isBookmarked(page);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'سُورَةُ $surahNameAr',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _kMushafText,
                ),
              ),
              Text(
                juzNameAr,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          toArabicNumber(page),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: _kMushafText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? _kMushafGreen : Colors.black,
            ),
            onPressed: () => ref
                .read(quranReaderNotifierProvider.notifier)
                .toggleBookmark(page),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: () => context.go('/quran'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Mushaf Page Header Image ──────────────────────────────
            _MushafPageHeader(),

            // ── QCF Page Content ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: QuranPageView(
                  pageController: _externalController,
                  highlights: const [],
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  isTajweed: false,
                  onPageChanged: (p) {
                    ref
                        .read(quranReaderNotifierProvider.notifier)
                        .updatePage(p);
                  },
                  onLongPress: (surahNumber, verseNumber, details) {
                    // Optional features
                  },
                ),
              ),
            ),

            // ── Mushaf Footer ──────────────────────────────────────────
            const _MushafFooter(),
          ],
        ),
      ),
    );
  }
}

class _MushafPageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/quran_page_header.png',
      width: double.infinity,
      fit: BoxFit.fitWidth,
    );
  }
}

class _MushafFooter extends StatelessWidget {
  const _MushafFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Image.asset(
        'assets/icons/quran_page_footer.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
