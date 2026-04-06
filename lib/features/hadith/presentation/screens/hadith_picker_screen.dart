import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_matn_hub_flutter/core/utils/hadith_helpers.dart';
import '../../domain/providers/hadith_providers.dart';

class HadithPickerScreen extends ConsumerWidget {
  const HadithPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = [
      {
        'name': 'Sahih al-Bukhari',
        'key': 'bukhari',
        'color': const Color(0xFF007A33),
      },
      {
        'name': 'Sahih Muslim',
        'key': 'muslim',
        'color': const Color(0xFF007A33),
      },
      {
        'name': 'Sunan Abi Dawud',
        'key': 'abu_dawud',
        'color': const Color(0xFFB8860B),
      },
      {
        'name': 'Jami\' at-Tirmidhi',
        'key': 'tirmidhi',
        'color': const Color(0xFFB8860B),
      },
      {
        'name': 'Sunan an-Nasa\'i',
        'key': 'nasai',
        'color': const Color(0xFF8B4513),
      },
      {
        'name': 'Sunan Ibn Majah',
        'key': 'ibn_majah',
        'color': const Color(0xFF8B4513),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith'),
        centerTitle: false,
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

                  return Container(
                    margin: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007A33), Color(0xFF00A344)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007A33).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(
                          '/hadith/${lastRead['bookKey']}/${lastRead['chapterNumber']}',
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Continue Reading',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bookName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Chapter ${lastRead['chapterNumber']} · ${formatHadithReference(lastRead['reference'])}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
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
  final Color color;
  final VoidCallback onTap;

  const _BookCard({
    required this.name,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, color: color, size: 40),
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
