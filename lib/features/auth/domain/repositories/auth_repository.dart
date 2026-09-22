import '../entities/authenticated_user.dart';

/// Abstract repository defining authentication operations.
abstract class AuthRepository {
  /// Authenticates a user with username and password.
  /// Throws a [Failure] on error or returns [AuthenticatedUser] on success.
  Future<AuthenticatedUser> login({
    required String username,
    required String password,
  });
}
