import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

/// Login usecase executing authentication via AuthRepository contract.
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<AuthenticatedUser> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(
      username: username,
      password: password,
    );
  }
}
