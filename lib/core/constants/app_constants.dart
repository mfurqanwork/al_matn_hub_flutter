/// App-wide compile-time constants.
abstract final class AppConstants {
  /// Total readable Mushaf pages (1–604). page_000.webp is excluded.
  static const int totalPages = 604;

  /// Total Juz count in the Quran.
  static const int totalJuz = 30;

  /// Total Surah count in the Quran.
  static const int totalSurahs = 114;

  // ── SharedPreferences keys ──────────────────────────────────────────────
  static const String prefLastReadPage = 'last_read_page';
  static const String prefBookmarks = 'bookmarks';

  // ── Asset path ──────────────────────────────────────────────────────────
  static const String quranAssetDir = 'assets/quran';
}
