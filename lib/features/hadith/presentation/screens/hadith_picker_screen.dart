import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/hadith_providers.dart';
import '../../../../core/widgets/continue_reading_banner.dart';

class HadithPickerScreen extends ConsumerWidget {
  const HadithPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final books = [
      {
        'name': 'Sahih al-Bukhari',
        'key': 'bukhari',
        'color': const Color(0xFF007A33),
        'image': 'assets/images/hadith_books/bukhari.png',
      },
      {
        'name': 'Sahih Muslim',
        'key': 'muslim',
        'color': const Color(0xFF007A33),
        'image': 'assets/images/hadith_books/muslim.png',
      },
      {
        'name': 'Sunan Abi Dawud',
        'key': 'abu_dawud',
        'color': const Color(0xFFB8860B),
        'image': 'assets/images/hadith_books/abu_dawud.png',
      },
      {
        'name': 'Jami\' at-Tirmidhi',
        'key': 'tirmidhi',
        'color': const Color(0xFFB8860B),
        'image': 'assets/images/hadith_books/tirmidhi.png',
      },
      {
        'name': 'Sunan an-Nasa\'i',
        'key': 'nasai',
        'color': const Color(0xFF8B4513),
        'image': 'assets/images/hadith_books/nasai.png',
      },
      {
        'name': 'Sunan Ibn Majah',
        'key': 'ibn_majah',
        'color': const Color(0xFF8B4513),
        'image': 'assets/images/hadith_books/ibn_majah.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(
              'Hadith',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Continue Reading Banner
          ref
              .watch(hadithReaderNotifierProvider)
              .when(
                data: (state) {
                  if (state.lastRead == null) return const SizedBox.shrink();

                  final lastRead = state.lastRead!;
                  final bookTitles = {
                    'bukhari': 'Sahih al-Bukhari',
                    'muslim': 'Sahih Muslim',
                    'abu_dawud': 'Sunan Abi Dawud',
                    'tirmidhi': 'Jami\' at-Tirmidhi',
                    'nasai': 'Sunan an-Nasa\'i',
                    'ibn_majah': 'Sunan Ibn Majah',
                  };

                  final bookName = bookTitles[lastRead['bookKey']] ?? 'Hadith';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: ContinueReadingBanner(
                      title: 'Continue Reading',
                      subtitle:
                          '$bookName · Ch ${lastRead['chapterNumber']} · ${lastRead['reference'].split(':').last}',
                      icon: 'assets/icons/ic_quran.png',
                      onTap: () => context.push(
                        '/hadith/${lastRead['bookKey']}/${lastRead['chapterNumber']}',
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                    value:
                        ref
                            .watch(hadithReaderNotifierProvider)
                            .value
                            ?.autoTracingEnabled ??
                        true,
                    activeColor: const Color(0xFF007A33),
                    onChanged: (val) => ref
                        .read(hadithReaderNotifierProvider.notifier)
                        .toggleAutoTracing(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return _BookCard(
                  name: book['name'] as String,
                  image: book['image'] as String,
                  color: book['color'] as Color,
                  onTap: () => context.push('/hadith/${book['key']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String name;
  final String image;
  final Color color;
  final VoidCallback onTap;

  const _BookCard({
    required this.name,
    required this.image,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    image,
                    width: 90,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
