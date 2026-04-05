import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/hadith_model.dart';

class HadithRepository {
  static const String boxName = 'hadith_box';
  static const String stateBoxName = 'hadith_state';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<List<dynamic>>(boxName);
    }
    if (!Hive.isBoxOpen(stateBoxName)) {
      await Hive.openBox(stateBoxName);
    }
  }

  Future<List<Hadith>> getHadithsByBook(String bookKey, {int? chapterNumber}) async {
    await init();
    final box = Hive.box<List<dynamic>>(boxName);
    final cachedData = box.get(bookKey);

    List<Hadith> hadiths;
    if (cachedData != null) {
      hadiths = cachedData.cast<Hadith>();
    } else {
      // Load from assets if not in Hive
      final String jsonString = await rootBundle.loadString('assets/hadith/$bookKey.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      hadiths = jsonList.map((e) => Hadith.fromJson(e)).toList();

      // Cache in Hive
      await box.put(bookKey, hadiths);
    }
    
    if (chapterNumber != null) {
      return hadiths.where((h) => h.Chapter_Number == chapterNumber).toList();
    }
    return hadiths;
  }

  Future<List<Map<String, dynamic>>> getChaptersByBook(String bookKey) async {
    final hadiths = await getHadithsByBook(bookKey);
    final SeenChapters = <int>{};
    final chapters = <Map<String, dynamic>>[];

    for (final h in hadiths) {
      if (!SeenChapters.contains(h.Chapter_Number)) {
        SeenChapters.add(h.Chapter_Number);
        chapters.add({
          'number': h.Chapter_Number,
          'title_english': h.Chapter_Title_English ?? 'Chapter ${h.Chapter_Number}',
          'title_arabic': h.Chapter_Title_Arabic ?? '',
        });
      }
    }
    return chapters;
  }

  Future<List<Hadith>> searchHadiths(String query, {String? bookKey}) async {
    await init();
    List<Hadith> allHadiths = [];
    if (bookKey != null) {
      allHadiths = await getHadithsByBook(bookKey);
    } else {
      // Search all books (this might be heavy, but Hive makes it faster if cached)
      final books = ['bukhari', 'muslim', 'abu_dawud', 'tirmidhi', 'nasai', 'ibn_majah'];
      for (final book in books) {
        allHadiths.addAll(await getHadithsByBook(book));
      }
    }

    return allHadiths.where((h) => 
      h.English_Text.toLowerCase().contains(query.toLowerCase()) || 
      h.Arabic_Text.contains(query)
    ).toList();
  }
  Future<void> saveLastRead({
    required String bookKey,
    required int chapterNumber,
    required int hadithIndex,
    required String reference,
  }) async {
    await init();
    final box = Hive.box(stateBoxName);
    await box.put('lastRead', {
      'bookKey': bookKey,
      'chapterNumber': chapterNumber,
      'hadithIndex': hadithIndex,
      'reference': reference,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    await init();
    final box = Hive.box(stateBoxName);
    final data = box.get('lastRead');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> toggleBookmark(Hadith hadith) async {
    await init();
    final box = Hive.box(stateBoxName);
    final bookmarksData = box.get('bookmarks', defaultValue: <dynamic>[]);
    final List<Hadith> bookmarks = List<dynamic>.from(bookmarksData).cast<Hadith>();

    final index = bookmarks.indexWhere((h) => h.Reference == hadith.Reference);
    if (index >= 0) {
      bookmarks.removeAt(index);
    } else {
      bookmarks.add(hadith);
    }
    await box.put('bookmarks', bookmarks);
  }

  Future<List<Hadith>> getBookmarks() async {
    await init();
    final box = Hive.box(stateBoxName);
    final bookmarksData = box.get('bookmarks', defaultValue: <dynamic>[]);
    return List<dynamic>.from(bookmarksData).cast<Hadith>();
  }
}
