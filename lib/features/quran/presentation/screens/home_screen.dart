import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quran_reader_notifier.dart';
import '../../../../core/utils/quran_helpers.dart';
import '../../../hadith/domain/providers/hadith_providers.dart';
import '../../../../core/widgets/continue_reading_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readerState = ref.watch(quranReaderNotifierProvider);
    final lastReadPage = readerState.value?.lastReadPage ?? 1;
    final lastReadLabel = pageOverlayLabel(lastReadPage);

    final hadithState = ref.watch(hadithReaderNotifierProvider).value;
    final lastHadith = hadithState?.lastRead;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/icons/logo.png', width: 32, height: 32),
            const SizedBox(width: 8),
            Text(
              'Al-Matn Hub',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Continue Reading Section ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContinueReadingBanner(
                  title: 'Continue Quran',
                  subtitle: '$lastReadLabel · Page $lastReadPage',
                  icon: 'assets/icons/ic_quran.png',
                  onTap: () => context.go('/quran/reader?page=$lastReadPage'),
                ),
                if (lastHadith != null) ...[
                  const SizedBox(height: 12),
                  ContinueReadingBanner(
                    title: 'Continue Hadith',
                    subtitle:
                        '${_getBookTitle(lastHadith['bookKey'])} · Ch ${lastHadith['chapterNumber']}',
                    icon: 'assets/icons/ic_quran.png',
                    onTap: () => context.go(
                      '/hadith/${lastHadith['bookKey']}/${lastHadith['chapterNumber']}',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ActionCard(
                  title: 'Quran',
                  subtitle: 'Read Quran',
                  icon: 'assets/icons/ic_quran.png',
                  color: const Color(0xFFB8860B),
                  onTap: () => context.go('/quran'),
                ),
                _ActionCard(
                  title: 'Hadith Books',
                  subtitle: 'Read 6 major books',
                  icon: 'assets/icons/ic_quran.png',
                  color: const Color(0xFF8B4513),
                  onTap: () => context.go('/hadith'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _getBookTitle(String key) {
  switch (key) {
    case 'bukhari':
      return 'Sahih al-Bukhari';
    case 'muslim':
      return 'Sahih Muslim';
    case 'abu_dawud':
      return 'Sunan Abi Dawud';
    case 'tirmidhi':
      return 'Jami\' at-Tirmidhi';
    case 'nasai':
      return 'Sunan an-Nasa\'i';
    case 'ibn_majah':
      return 'Sunan Ibn Majah';
    default:
      return 'Hadith Book';
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(icon, width: 32, height: 32),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
