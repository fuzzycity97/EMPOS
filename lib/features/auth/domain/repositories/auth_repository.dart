import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser?>> loginWithPin(String pin);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, void>> seedDefaultUsers();
}
