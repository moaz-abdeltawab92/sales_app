import '../../../../core/errors/failures.dart';
import '../models/authenticated_user_model.dart';

/// Abstract data source interface for authentication operations.
abstract class AuthRemoteDataSource {
  Future<AuthenticatedUserModel> login({
    required String username,
    required String password,
  });
}

/// Temporary Mock Data Source implementation for local testing while awaiting Odoo credentials.
/// This will be replaced by OdooAuthRemoteDataSource once API details are provided.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthenticatedUserModel> login({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (username.trim().isEmpty || password.trim().isEmpty) {
      throw const AuthenticationFailure(
        'Username and password cannot be empty',
      );
    }

    return AuthenticatedUserModel(
      id: 1,
      username: username.trim(),
      name: 'Test User',
      isInternalUser: true,
    );
  }
}
