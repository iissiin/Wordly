import 'package:flutter/material.dart';

/// Временная модель для полей формы.
/// Не является domain entity — используется только в UI.
class WordEntry {
  final String id; // пустая строка = новое слово
  final TextEditingController originalController;
  final TextEditingController translationController;

  WordEntry({
    this.id = '',
    String original = '',
    String translation = '',
  })  : originalController = TextEditingController(text: original),
        translationController = TextEditingController(text: translation);

  String get original => originalController.text.trim();
  String get translation => translationController.text.trim();

  bool get isNew => id.isEmpty;
  bool get isEmpty => original.isEmpty && translation.isEmpty;
  bool get isValid => original.isNotEmpty && translation.isNotEmpty;

  void dispose() {
    originalController.dispose();
    translationController.dispose();
  }
}
