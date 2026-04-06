import 'package:flutter/material.dart';
import '../../data/models/hadith_model.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;

  const HadithCard({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reference info
            if (hadith.In_book_reference != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  hadith.In_book_reference!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF007A33),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // English text
            Text(
              hadith.cleanEnglish,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
