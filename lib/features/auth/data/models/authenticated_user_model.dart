import '../../domain/entities/authenticated_user.dart';

/// Data model representing authenticated user data from backend/data sources.
class AuthenticatedUserModel extends AuthenticatedUser {
  const AuthenticatedUserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.isInternalUser,
  });

  /// Creates [AuthenticatedUserModel] from JSON payload.
  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isInternalUser: json['is_internal_user'] as bool? ?? false,
    );
  }

  /// Converts [AuthenticatedUserModel] instance to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'is_internal_user': isInternalUser,
    };
  }
}
