import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppUser?>> loginWithPin(String pin) async {
    try {
      final user = await localDataSource.loginWithPin(pin);
      if (user == null) {
        return const Left(AuthFailure(message: 'Invalid PIN code. Access denied.'));
      }
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to authenticate PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve current user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultUsers() async {
    try {
      await localDataSource.seedDefaultUsers();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to seed default users: $e'));
    }
  }
}
