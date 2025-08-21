import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/error_model.dart';

abstract class UseCase<Type, Params> {
  Future<Either<ErrorModel, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

