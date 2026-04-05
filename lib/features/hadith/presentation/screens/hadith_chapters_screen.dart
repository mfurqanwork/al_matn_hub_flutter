import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:al_matn_hub_flutter/core/utils/hadith_helpers.dart';
import '../../domain/providers/hadith_providers.dart';

class HadithChaptersScreen extends ConsumerWidget {
  final String bookKey;

  const HadithChaptersScreen({super.key, required this.bookKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider(bookKey));

    final bookTitles = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'abu_dawud': 'Sunan Abi Dawud',
      'tirmidhi': 'Jami\' at-Tirmidhi',
      'nasai': 'Sunan an-Nasa\'i',
      'ibn_majah': 'Sunan Ibn Majah',
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${bookTitles[bookKey]} Chapters'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A33).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chapter['number']}',
                      style: const TextStyle(
                        color: Color(0xFF007A33),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    cleanChapterTitle(chapter['title_english']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () =>
                      context.push('/hadith/$bookKey/${chapter['number']}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF007A33)),
        ),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
