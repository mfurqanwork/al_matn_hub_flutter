import 'package:hive/hive.dart';
import 'package:al_matn_hub_flutter/core/utils/hadith_helpers.dart';

class Hadith {
  final String Book;
  final int Chapter_Number;
  final String? Chapter_Title_Arabic;
  final String? Chapter_Title_English;
  final String Arabic_Text;
  final String English_Text;
  final String? Grade;
  final String? Reference;
  final String? In_book_reference;

  const Hadith({
    required this.Book,
    required this.Chapter_Number,
    this.Chapter_Title_Arabic,
    this.Chapter_Title_English,
    required this.Arabic_Text,
    required this.English_Text,
    this.Grade,
    this.Reference,
    this.In_book_reference,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      Book: json['Book'] as String,
      Chapter_Number: (json['Chapter_Number'] as num).toInt(),
      Chapter_Title_Arabic: json['Chapter_Title_Arabic'] as String?,
      Chapter_Title_English: json['Chapter_Title_English'] as String?,
      Arabic_Text: json['Arabic_Text'] as String,
      English_Text: cleanHadithText(json['English_Text'] as String),
      Grade: json['Grade'] as String?,
      Reference: json['Reference'] as String?,
      In_book_reference: json['In_book_reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Book': Book,
      'Chapter_Number': Chapter_Number,
      'Chapter_Title_Arabic': Chapter_Title_Arabic,
      'Chapter_Title_English': Chapter_Title_English,
      'Arabic_Text': Arabic_Text,
      'English_Text': English_Text,
      'Grade': Grade,
      'Reference': Reference,
      'In_book_reference': In_book_reference,
    };
  }

  String get formattedReference {
    if (Reference == null) return '';
    if (!Reference!.startsWith('http')) return Reference!;
    final part = Reference!.split('/').last;
    if (part.contains(':')) {
      final components = part.split(':');
      final book = components[0];
      final num = components[1];
      return '${book[0].toUpperCase()}${book.substring(1)} $num';
    }
    return part;
  }

  String? get displayGrade {
    if (Grade != null && Grade!.trim().isNotEmpty) return Grade;
    final b = Book.toLowerCase();
    if (b.contains('bukhari') || b.contains('muslim')) {
      return 'Sahih';
    }
    return null;
  }

  String? get displayChapterTitle {
    if (Chapter_Title_English == null) return null;
    return cleanChapterTitle(Chapter_Title_English!);
  }

  String get cleanEnglish => cleanHadithText(English_Text);
  String get cleanArabic => cleanHadithText(Arabic_Text);
}

class HadithAdapter extends TypeAdapter<Hadith> {
  @override
  final int typeId = 0;

  @override
  Hadith read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hadith(
      Book: fields[0] as String,
      Chapter_Number: fields[1] as int,
      Chapter_Title_Arabic: fields[2] as String?,
      Chapter_Title_English: fields[3] as String?,
      Arabic_Text: fields[4] as String,
      English_Text: fields[5] as String,
      Grade: fields[6] as String?,
      Reference: fields[7] as String?,
      In_book_reference: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Hadith obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.Book)
      ..writeByte(1)
      ..write(obj.Chapter_Number)
      ..writeByte(2)
      ..write(obj.Chapter_Title_Arabic)
      ..writeByte(3)
      ..write(obj.Chapter_Title_English)
      ..writeByte(4)
      ..write(obj.Arabic_Text)
      ..writeByte(5)
      ..write(obj.English_Text)
      ..writeByte(6)
      ..write(obj.Grade)
      ..writeByte(7)
      ..write(obj.Reference)
      ..writeByte(8)
      ..write(obj.In_book_reference);
  }
}
