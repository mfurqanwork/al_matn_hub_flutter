import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;

// ── Data models ──────────────────────────────────────────────────────────────

class SurahInfo {
  const SurahInfo({
    required this.number,
    required this.name,
    required this.startPage,
    required this.verseCount,
  });

  final int number;
  final String name;
  final int startPage;
  final int verseCount;
}

class JuzInfo {
  const JuzInfo({required this.number, required this.startPage});

  final int number;
  final int startPage;
}

class SurahSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

// ── Providers (computed once, no rebuilds) ────────────────────────────────────

/// All 114 surahs ordered by number.
final surahListProvider = Provider<List<SurahInfo>>((ref) {
  return List.generate(114, (i) {
    final n = i + 1;
    return SurahInfo(
      number: n,
      name: quran.getSurahName(n),
      startPage: quran.getPageNumber(n, 1),
      verseCount: quran.getVerseCount(n),
    );
  });
});

/// All 30 juz entries with their first Mushaf page.
final juzListProvider = Provider<List<JuzInfo>>((ref) {
  return List.generate(30, (i) {
    final juzNum = i + 1;
    final data = quran.getSurahAndVersesFromJuz(juzNum);
    final startSurah = data.keys.first;
    final startVerse = data[startSurah]!.first;
    final startPage = quran.getPageNumber(startSurah, startVerse);
    return JuzInfo(number: juzNum, startPage: startPage);
  });
});

/// Filter query for the surah search bar.
final surahSearchProvider = NotifierProvider<SurahSearchNotifier, String>(
  SurahSearchNotifier.new,
);

/// Filtered surah list based on [surahSearchProvider].
final filteredSurahListProvider = Provider<List<SurahInfo>>((ref) {
  final all = ref.watch(surahListProvider);
  final query = ref.watch(surahSearchProvider).trim();
  if (query.isEmpty) return all;
  return all
      .where(
        (s) =>
            s.name.toLowerCase().contains(query.toLowerCase()) ||
            s.number.toString().contains(query),
      )
      .toList();
});
