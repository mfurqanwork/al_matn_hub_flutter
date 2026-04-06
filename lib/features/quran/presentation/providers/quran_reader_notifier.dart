import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

// ── State model ──────────────────────────────────────────────────────────────

class ReaderState {
  const ReaderState({
    required this.currentPage,
    required this.lastReadPage,
    required this.controlsVisible,
    required this.bookmarks,
    required this.autoTracingEnabled,
  });

  final int currentPage;
  final int lastReadPage;
  final bool controlsVisible;
  final List<int> bookmarks;
  final bool autoTracingEnabled;

  ReaderState copyWith({
    int? currentPage,
    int? lastReadPage,
    bool? controlsVisible,
    List<int>? bookmarks,
    bool? autoTracingEnabled,
  }) {
    return ReaderState(
      currentPage: currentPage ?? this.currentPage,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      bookmarks: bookmarks ?? this.bookmarks,
      autoTracingEnabled: autoTracingEnabled ?? this.autoTracingEnabled,
    );
  }

  bool isBookmarked(int page) => bookmarks.contains(page);
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class QuranReaderNotifier extends AsyncNotifier<ReaderState> {
  SharedPreferences? _prefs;
  int _fallbackLastPage = 1;
  List<int> _fallbackBookmarks = <int>[];

  @override
  Future<ReaderState> build() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      _prefs = null;
    }

    final lastPage =
        _prefs?.getInt(AppConstants.prefLastReadPage) ?? _fallbackLastPage;
    final bookmarks = _loadBookmarks();
    final autoTracing = _prefs?.getBool(AppConstants.prefQuranAutoTracing) ?? true;

    return ReaderState(
      currentPage: lastPage,
      lastReadPage: lastPage,
      controlsVisible: true,
      bookmarks: bookmarks,
      autoTracingEnabled: autoTracing,
    );
  }

  // ── Page ──────────────────────────────────────────────────────────────────

  void updatePage(int page) {
    final current = state.value;
    if (current == null) return;
    
    // Always update the reader's current page in-memory
    ReaderState newState = current.copyWith(currentPage: page);
    
    // Only update the lastReadPage and persist if auto-tracing is enabled
    if (current.autoTracingEnabled) {
      newState = newState.copyWith(lastReadPage: page);
      _prefs?.setInt(AppConstants.prefLastReadPage, page);
      _fallbackLastPage = page;
    }
    
    state = AsyncData(newState);
  }

  void toggleAutoTracing() {
    final current = state.value;
    if (current == null) return;
    final newValue = !current.autoTracingEnabled;
    state = AsyncData(current.copyWith(autoTracingEnabled: newValue));
    _prefs?.setBool(AppConstants.prefQuranAutoTracing, newValue);
  }

  // ── Controls visibility ───────────────────────────────────────────────────

  void toggleControls() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(controlsVisible: !current.controlsVisible),
    );
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  void toggleBookmark(int page) {
    final current = state.value;
    if (current == null) return;
    final updated = List<int>.from(current.bookmarks);
    if (updated.contains(page)) {
      updated.remove(page);
    } else {
      updated.add(page);
      updated.sort();
    }
    state = AsyncData(current.copyWith(bookmarks: updated));
    _saveBookmarks(updated);
  }

  // ── Persistence helpers ───────────────────────────────────────────────────

  List<int> _loadBookmarks() {
    final raw = _prefs?.getString(AppConstants.prefBookmarks);
    if (raw == null) return List<int>.from(_fallbackBookmarks);
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<int>();
    } catch (_) {
      return [];
    }
  }

  void _saveBookmarks(List<int> pages) {
    _fallbackBookmarks = List<int>.from(pages);
    _prefs?.setString(AppConstants.prefBookmarks, jsonEncode(pages));
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final quranReaderNotifierProvider =
    AsyncNotifierProvider<QuranReaderNotifier, ReaderState>(
      QuranReaderNotifier.new,
    );
