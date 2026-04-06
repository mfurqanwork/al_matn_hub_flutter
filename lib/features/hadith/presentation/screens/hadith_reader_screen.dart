import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:al_matn_hub_flutter/core/utils/hadith_helpers.dart';
import '../../domain/providers/hadith_providers.dart';
import '../widgets/hadith_card.dart';

class HadithReaderScreen extends ConsumerStatefulWidget {
  final String bookKey;
  final int chapterNumber;

  const HadithReaderScreen({
    super.key,
    required this.bookKey,
    required this.chapterNumber,
  });

  @override
  ConsumerState<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends ConsumerState<HadithReaderScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final hadithsAsync = ref.watch(
      loadHadithsByBookProvider((
        bookKey: widget.bookKey,
        chapterNumber: widget.chapterNumber,
      )),
    );

    final bookTitles = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'abu_dawud': 'Sunan Abi Dawud',
      'tirmidhi': 'Jami\' at-Tirmidhi',
      'nasai': 'Sunan an-Nasa\'i',
      'ibn_majah': 'Sunan Ibn Majah',
    };

    final readerState = ref.watch(hadithReaderNotifierProvider);
    final chaptersAsync = ref.watch(chaptersProvider(widget.bookKey));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: hadithsAsync.maybeWhen(
          data: (hadiths) {
            final chapterTitle = hadiths.isNotEmpty
                ? hadiths.first.displayChapterTitle
                : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitles[widget.bookKey] ?? 'Hadith',
                  style: const TextStyle(
                    fontSize: 14, // Even smaller
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chapterTitle != null
                      ? 'Chapter ${widget.chapterNumber}: $chapterTitle'
                      : 'Chapter ${widget.chapterNumber}',
                  style: const TextStyle(
                    fontSize: 12, // Smaller
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  softWrap: true,
                ),
              ],
            );
          },
          orElse: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookTitles[widget.bookKey] ?? 'Hadith',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Chapter ${widget.chapterNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        actions: [
          hadithsAsync.when(
            data: (hadiths) {
              if (hadiths.isEmpty) return const SizedBox.shrink();
              final currentHadith =
                  hadiths[_currentIndex < hadiths.length ? _currentIndex : 0];
              final isBookmarked = ref
                  .watch(hadithReaderNotifierProvider.notifier)
                  .isBookmarked(currentHadith.Reference ?? '');

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? const Color(0xFF007A33)
                          : Colors.black,
                    ),
                    onPressed: () => ref
                        .read(hadithReaderNotifierProvider.notifier)
                        .toggleBookmark(currentHadith),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
            loading: () => IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 24),
              onPressed: () => context.pop(),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 24),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
      body: hadithsAsync.when(
        data: (hadiths) {
          if (hadiths.isEmpty) {
            return const Center(child: Text('No hadiths found.'));
          }

          if (!_isInitialized) {
            if (readerState.value?.lastRead?['bookKey'] == widget.bookKey &&
                readerState.value?.lastRead?['chapterNumber'] ==
                    widget.chapterNumber) {
              _currentIndex = readerState.value?.lastRead?['hadithIndex'] ?? 0;
              if (_currentIndex >= hadiths.length) _currentIndex = 0;
            }

            // Sync initial progress to ensure "Continue Reading" works even if user doesn't swipe
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && hadiths.isNotEmpty) {
                final h = hadiths[_currentIndex];
                ref
                    .read(hadithReaderNotifierProvider.notifier)
                    .saveProgress(
                      bookKey: widget.bookKey,
                      chapterNumber: widget.chapterNumber,
                      hadithIndex: _currentIndex,
                      reference: h.Reference ?? '',
                    );
              }
            });
            _isInitialized = true;
          }

          return Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / hadiths.length,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF007A33),
                ),
                minHeight: 2,
              ),
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: _currentIndex),
                  itemCount: hadiths.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    final h = hadiths[index];
                    ref
                        .read(hadithReaderNotifierProvider.notifier)
                        .saveProgress(
                          bookKey: widget.bookKey,
                          chapterNumber: widget.chapterNumber,
                          hadithIndex: index,
                          reference: h.Reference ?? '',
                        );
                  },
                  itemBuilder: (context, index) {
                    final h = hadiths[index];
                    final displayGrade = h.displayGrade;
                    final gradeColor = getGradeColor(displayGrade);

                    // Chapter navigation info
                    final nextPrev = chaptersAsync.maybeWhen(
                      data: (chapters) {
                        final currentIdx = chapters.indexWhere(
                          (c) => c['number'] == widget.chapterNumber,
                        );
                        return (
                          prev: currentIdx > 0
                              ? chapters[currentIdx - 1]['number'] as int
                              : null,
                          next: currentIdx < chapters.length - 1
                              ? chapters[currentIdx + 1]['number'] as int
                              : null,
                        );
                      },
                      orElse: () => (prev: null, next: null),
                    );

                    return Column(
                      children: [
                        // Pinned Reference and Grade Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                h.formattedReference,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (displayGrade != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gradeColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: gradeColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    displayGrade.toUpperCase(),
                                    style: TextStyle(
                                      color: gradeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Scrollable Hadith Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                HadithCard(hadith: h),
                                const SizedBox(height: 12),
                                Text(
                                  'Hadith ${index + 1} of ${hadiths.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (index == 0 && nextPrev.prev != null)
                                  _buildNavButton(
                                    context,
                                    nextPrev.prev!,
                                    false,
                                  ),
                                if (index == hadiths.length - 1 &&
                                    nextPrev.next != null)
                                  _buildNavButton(
                                    context,
                                    nextPrev.next!,
                                    true,
                                  ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF007A33)),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, int targetChapter, bool isNext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: InkWell(
        onTap: () =>
            context.pushReplacement('/hadith/${widget.bookKey}/$targetChapter'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isNext
                ? const Color(0xFF007A33).withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNext
                  ? const Color(0xFF007A33).withOpacity(0.1)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isNext)
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black54,
                ),
              if (!isNext) const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    isNext ? 'Next Chapter' : 'Previous Chapter',
                    style: TextStyle(
                      color: isNext ? const Color(0xFF007A33) : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Continue to Chapter $targetChapter',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              if (isNext) const SizedBox(width: 12),
              if (isNext)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF007A33),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
