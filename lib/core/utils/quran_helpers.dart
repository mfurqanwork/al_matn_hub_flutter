import 'package:quran/quran.dart' as quran;

import '../constants/app_constants.dart';

// ── Page ↔ ViewIndex helpers ─────────────────────────────────────────────────
//
// PageView is reversed (RTL Quran flip). Index 0 in PageView = page 604.
//
// viewIndex = totalPages - realPage
// realPage  = totalPages - viewIndex

int pageToViewIndex(int realPage) =>
    AppConstants.totalPages - realPage; // 604→0, 1→603

int viewIndexToPage(int viewIndex) => AppConstants.totalPages - viewIndex;

/// Returns the first Mushaf page number for [juz] (1–30).
int juzStartPage(int juz) {
  final data = quran.getSurahAndVersesFromJuz(juz);
  final startSurah = data.keys.first;
  final startVerse = data[startSurah]!.first;
  return quran.getPageNumber(startSurah, startVerse);
}

/// Returns the Mushaf page number for the first verse of [surah] (1–114).
int surahStartPage(int surah) => quran.getPageNumber(surah, 1);

/// Returns the primary surah number for [page] (1–604).
/// Uses the first entry in [quran.getPageData].
int surahNumberForPage(int page) {
  final data = quran.getPageData(page);
  return (data.first as Map)['surah'] as int;
}

/// Returns the transliterated surah name for [page] (1–604).
String surahNameForPage(int page) {
  final surahNum = surahNumberForPage(page);
  return quran.getSurahName(surahNum);
}

/// Returns a short overlay label: "Surah Al-Fatiha · Juz 1"
String pageOverlayLabel(int page) {
  final surahNum = surahNumberForPage(page);
  final juzNum = quran.getJuzNumber(surahNum, 1);
  final surahName = quran.getSurahName(surahNum);
  return 'Surah $surahName · Juz $juzNum';
}
