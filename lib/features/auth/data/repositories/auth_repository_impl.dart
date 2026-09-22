import '../../../../core/errors/failures.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Concrete implementation of [AuthRepository] handling authentication data flow.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthenticatedUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return userModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
