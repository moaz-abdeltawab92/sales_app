import '../../../../core/errors/failures.dart';
import '../../../../core/network/odoo_rpc_client.dart';
import '../models/authenticated_user_model.dart';
import 'auth_remote_data_source.dart';

/// Odoo JSON-RPC implementation of [AuthRemoteDataSource].
class OdooAuthRemoteDataSource implements AuthRemoteDataSource {
  final OdooRpcClient client;

  OdooAuthRemoteDataSource({required this.client});

  @override
  Future<AuthenticatedUserModel> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    if (cleanUsername.isEmpty) {
      throw const AuthenticationFailure('Username cannot be empty');
    }

    if (cleanPassword.isEmpty) {
      throw const AuthenticationFailure('Password is required');
    }

    // Authenticate via JSON-RPC
    final uid = await client.authenticate(
      username: cleanUsername,
      password: cleanPassword,
    );

    // Fetch user info from `res.users` to determine display name and role
    String displayName = cleanUsername;
    bool isInternal = true;

    try {
      final userRecords = await client.executeKw(
        model: 'res.users',
        method: 'search_read',
        args: [
          [
            ['id', '=', uid],
          ],
        ],
        kwargs: {
          'fields': ['name', 'login', 'email', 'share'],
          'limit': 1,
        },
      );

      if (userRecords is List && userRecords.isNotEmpty) {
        final Map<String, dynamic> userRecord = Map<String, dynamic>.from(
          userRecords.first as Map,
        );

        final name = OdooRpcClient.parseString(userRecord['name']);
        if (name.isNotEmpty) {
          displayName = name;
        }

        // In Odoo: share == false indicates an Internal User (Employee),
        // share == true indicates a Portal/Public external user.
        final share = OdooRpcClient.parseBool(userRecord['share'], false);
        isInternal = !share;
      }
    } catch (_) {
      // If fetching detailed res.users fails, fallback safely to authenticated user defaults
    }

    return AuthenticatedUserModel(
      id: uid,
      username: cleanUsername,
      name: displayName,
      isInternalUser: isInternal,
    );
  }
}
