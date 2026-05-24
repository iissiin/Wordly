import 'package:equatable/equatable.dart';
import '../../../domain/entities/dictionary.dart';

abstract class DictionaryState extends Equatable {
  const DictionaryState();

  @override
  List<Object?> get props => [];
}

class DictionaryInitial extends DictionaryState {
  const DictionaryInitial();
}

class DictionaryLoading extends DictionaryState {
  const DictionaryLoading();
}

class DictionarySuccess extends DictionaryState {
  final Dictionary? dictionary;
  const DictionarySuccess({this.dictionary});

  @override
  List<Object?> get props => [dictionary];
}

class DictionaryError extends DictionaryState {
  final String message;
  const DictionaryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Отдельный state для операций (создание/удаление/обновление)
// чтобы не перезаписывать основной state экрана
class DictionaryOperationSuccess extends DictionaryState {
  final String message;
  const DictionaryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
