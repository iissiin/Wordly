enum TranslationDirection {
  originalToTranslation,
  translationToOriginal,
}

class QuizSettings {
  final TranslationDirection direction;
  final bool randomOrder;

  const QuizSettings({
    this.direction = TranslationDirection.originalToTranslation,
    this.randomOrder = true,
  });

  QuizSettings copyWith({
    TranslationDirection? direction,
    bool? randomOrder,
  }) {
    return QuizSettings(
      direction: direction ?? this.direction,
      randomOrder: randomOrder ?? this.randomOrder,
    );
  }
}
