import 'package:flutter/material.dart';

String formatHadithReference(String? reference) {
  if (reference == null || reference.isEmpty) return '';
  if (!reference.startsWith('http')) return reference;
  
  final part = reference.split('/').last;
  if (part.contains(':')) {
    final components = part.split(':');
    final book = components[0];
    final num = components[1];
    // Capitalize first letter of book
    return '${book[0].toUpperCase()}${book.substring(1)} $num';
  }
  return part;
}

String cleanChapterTitle(String title) {
  if (title.toLowerCase().startsWith('chapter')) {
    final colonIndex = title.indexOf(':');
    if (colonIndex != -1 && colonIndex < 15) {
      return title.substring(colonIndex + 1).trim();
    }
  }
  return title;
}

/// Removes extra whitespaces and newlines from text.
String cleanHadithText(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

Color getGradeColor(String? grade) {
  if (grade == null) return const Color(0xFF6B7280); // Gray-500
  final lower = grade.toLowerCase();
  if (lower.contains('sahih')) return const Color(0xFF007A33); // Emerald
  if (lower.contains('hasan')) return const Color(0xFFB8860B); // DarkGoldenRod
  if (lower.contains('daif')) return const Color(0xFFDC2626); // Red-600
  return const Color(0xFF6B7280);
}
