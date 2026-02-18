import 'package:flutter/material.dart';

import '../../../../core/utils/quran_helpers.dart';

/// A single Mushaf page rendered from the bundled .webp asset.
/// Wrapped in [InteractiveViewer] for pinch-zoom (0.9×–4×).
/// This widget is intentionally const and has no state – all
/// state lives in QuranReaderNotifier.
class QuranPageWidget extends StatelessWidget {
  const QuranPageWidget({super.key, required this.pageNum});

  final int pageNum;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InteractiveViewer(
        minScale: 0.9,
        maxScale: 4.0,
        child: Center(
          child: Image.asset(
            pageAssetPath(pageNum),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            // Cachewidth hint: feed Flutter's image cache with the
            // physical pixel width so it doesn't keep over-sized bitmaps.
            cacheWidth: MediaQuery.sizeOf(context).width.toInt() * 2,
            errorBuilder: (context2, error, stackTrace) =>
                _PageErrorWidget(page: pageNum),
          ),
        ),
      ),
    );
  }
}

class _PageErrorWidget extends StatelessWidget {
  const _PageErrorWidget({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, size: 48),
          const SizedBox(height: 8),
          Text(
            'الصفحة $page غير متاحة',
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
          ),
        ],
      ),
    );
  }
}
