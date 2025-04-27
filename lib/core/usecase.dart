import 'package:dartz/dartz.dart';
import 'package:track_it_up/core/errors/failure.dart';


abstract class UseCase<Type, Param> {
  Future<Either<Failure, Type>> call(Param params);
}
