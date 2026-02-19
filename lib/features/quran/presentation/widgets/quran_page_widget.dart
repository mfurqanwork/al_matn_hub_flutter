import 'package:flutter/material.dart';

import '../../../../core/utils/quran_helpers.dart';

/// Legacy image-based Quran page widget (kept as backup).
/// The app now uses qcf_quran's PageviewQuran for rendering.
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
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
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
