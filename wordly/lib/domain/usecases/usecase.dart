// ignore_for_file: avoid_types_as_parameter_names

abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Для Use Cases без параметров
class NoParams {
  const NoParams();
}
