import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hadith_model.dart';
import '../../data/repositories/hadith_repository.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository();
});

final loadHadithsByBookProvider = FutureProvider.family<List<Hadith>, ({String bookKey, int? chapterNumber})>((ref, args) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getHadithsByBook(args.bookKey, chapterNumber: args.chapterNumber);
});

final chaptersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, bookKey) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getChaptersByBook(bookKey);
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class HadithReaderState {
  final Map<String, dynamic>? lastRead;
  final List<Hadith> bookmarks;

  const HadithReaderState({
    this.lastRead,
    this.bookmarks = const [],
  });

  HadithReaderState copyWith({
    Map<String, dynamic>? lastRead,
    List<Hadith>? bookmarks,
  }) {
    return HadithReaderState(
      lastRead: lastRead ?? this.lastRead,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class HadithReaderNotifier extends AsyncNotifier<HadithReaderState> {
  @override
  Future<HadithReaderState> build() async {
    final repo = ref.watch(hadithRepositoryProvider);
    final lastRead = await repo.getLastRead();
    final bookmarks = await repo.getBookmarks();
    return HadithReaderState(lastRead: lastRead, bookmarks: bookmarks);
  }

  Future<void> saveProgress({
    required String bookKey,
    required int chapterNumber,
    required int hadithIndex,
    required String reference,
  }) async {
    final repo = ref.read(hadithRepositoryProvider);
    await repo.saveLastRead(
      bookKey: bookKey,
      chapterNumber: chapterNumber,
      hadithIndex: hadithIndex,
      reference: reference,
    );
    state = AsyncValue.data(state.value!.copyWith(
      lastRead: {
        'bookKey': bookKey,
        'chapterNumber': chapterNumber,
        'hadithIndex': hadithIndex,
        'reference': reference,
      },
    ));
  }

  Future<void> toggleBookmark(Hadith hadith) async {
    final repo = ref.read(hadithRepositoryProvider);
    await repo.toggleBookmark(hadith);
    final updatedBookmarks = await repo.getBookmarks();
    state = AsyncValue.data(state.value!.copyWith(bookmarks: updatedBookmarks));
  }

  bool isBookmarked(String reference) {
    if (!state.hasValue) return false;
    return state.value!.bookmarks.any((h) => h.Reference == reference);
  }
}

final hadithReaderNotifierProvider = AsyncNotifierProvider<HadithReaderNotifier, HadithReaderState>(
  HadithReaderNotifier.new,
);

class SearchHadithQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchHadithQueryProvider = NotifierProvider<SearchHadithQuery, String>(
  SearchHadithQuery.new,
);

final searchHadithsProvider = FutureProvider.family<List<Hadith>, String?>((ref, bookKey) async {
  final query = ref.watch(searchHadithQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.searchHadiths(query, bookKey: bookKey);
});
