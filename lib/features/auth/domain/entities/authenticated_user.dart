import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user in the system.
class AuthenticatedUser extends Equatable {
  final int id;
  final String username;
  final String name;
  final bool isInternalUser;

  const AuthenticatedUser({
    required this.id,
    required this.username,
    required this.name,
    required this.isInternalUser,
  });

  @override
  List<Object?> get props => [id, username, name, isInternalUser];
}
