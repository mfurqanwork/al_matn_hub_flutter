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

String toArabicNumber(int number) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String text = number.toString();
  for (int i = 0; i < english.length; i++) {
    text = text.replaceAll(english[i], arabic[i]);
  }
  return text;
}

const List<String> arabicJuzNames = [
  "الجزء الأول",
  "الجزء الثاني",
  "الجزء الثالث",
  "الجزء الرابع",
  "الجزء الخامس",
  "الجزء السادس",
  "الجزء السابع",
  "الجزء الثامن",
  "الجزء التاسع",
  "الجزء العاشر",
  "الجزء الحادي عشر",
  "الجزء الثاني عشر",
  "الجزء الثالث عشر",
  "الجزء الرابع عشر",
  "الجزء الخامس عشر",
  "الجزء السادس عشر",
  "الجزء السابع عشر",
  "الجزء الثامن عشر",
  "الجزء التاسع عشر",
  "الجزء العشرون",
  "الجزء الحادي والعشرون",
  "الجزء الثاني والعشرون",
  "الجزء الثالث والعشرون",
  "الجزء الرابع والعشرون",
  "الجزء الخامس والعشرون",
  "الجزء السادس والعشرون",
  "الجزء السابع والعشرون",
  "الجزء الثامن والعشرون",
  "الجزء التاسع والعشرون",
  "الجزء الثلاثون",
];

String getJuzNameArabic(int juzInt) {
  if (juzInt >= 1 && juzInt <= 30) {
    return arabicJuzNames[juzInt - 1];
  }
  return "الجزء ${toArabicNumber(juzInt)}";
}
