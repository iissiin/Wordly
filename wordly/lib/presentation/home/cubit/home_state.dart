import 'package:equatable/equatable.dart';
import '../../../domain/entities/dictionary.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Dictionary> dictionaries;
  const HomeLoaded(this.dictionaries);

  @override
  List<Object?> get props => [dictionaries];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
