import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:al_matn_hub_flutter/features/quran/presentation/providers/quran_reader_notifier.dart';
import 'package:al_matn_hub_flutter/core/utils/quran_helpers.dart';
import 'package:al_matn_hub_flutter/features/hadith/data/models/hadith_model.dart';
import 'package:al_matn_hub_flutter/features/hadith/domain/providers/hadith_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranReaderAsync = ref.watch(quranReaderNotifierProvider);
    final hadithReaderAsync = ref.watch(hadithReaderNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/logo.png', width: 28, height: 28),
              const SizedBox(width: 8),
              const Text(
                'Bookmarks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Color(0xFF007A33),
            labelColor: Color(0xFF007A33),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Quran'),
              Tab(text: 'Hadith'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Quran Bookmarks
            quranReaderAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (reader) =>
                  _buildQuranBookmarks(context, ref, reader.bookmarks),
            ),
            // Hadith Bookmarks
            hadithReaderAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (reader) =>
                  _buildHadithBookmarks(context, ref, reader.bookmarks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranBookmarks(
    BuildContext context,
    WidgetRef ref,
    List<int> bookmarks,
  ) {
    if (bookmarks.isEmpty) return _buildEmptyState('No Quran bookmarks yet');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final page = bookmarks[index];
        final label = pageOverlayLabel(page);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _buildIndexCircle(index + 1),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Page $page'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => ref
                  .read(quranReaderNotifierProvider.notifier)
                  .toggleBookmark(page),
            ),
            onTap: () => context.go('/quran/reader?page=$page'),
          ),
        );
      },
    );
  }

  Widget _buildHadithBookmarks(
    BuildContext context,
    WidgetRef ref,
    List<Hadith> bookmarks,
  ) {
    if (bookmarks.isEmpty) return _buildEmptyState('No Hadith bookmarks yet');

    final bookTitles = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'abu_dawud': 'Sunan Abi Dawud',
      'tirmidhi': 'Jami\' at-Tirmidhi',
      'nasai': 'Sunan an-Nasa\'i',
      'ibn_majah': 'Sunan Ibn Majah',
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final h = bookmarks[index];
        final bookName = bookTitles[h.Book.toLowerCase()] ?? h.Book;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _buildIndexCircle(index + 1),
            title: Text(
              bookName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Chapter ${h.Chapter_Number} · ${h.formattedReference}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => ref
                  .read(hadithReaderNotifierProvider.notifier)
                  .toggleBookmark(h),
            ),
            onTap: () => context.push(
              '/hadith/${h.Book.toLowerCase()}/${h.Chapter_Number}',
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndexCircle(int index) {
    return CircleAvatar(
      backgroundColor: const Color(0xFF007A33).withOpacity(0.1),
      child: Text(
        '$index',
        style: const TextStyle(
          color: Color(0xFF007A33),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
