import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dictionary.dart';
import 'word_model.dart';

class DictionaryModel extends Dictionary {
  const DictionaryModel({
    required super.id,
    required super.name,
    super.description,
    super.words,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DictionaryModel.fromMap(
    Map<String, dynamic> map, {
    List<WordModel> words = const [],
  }) {
    return DictionaryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      words: words,
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
