import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred']);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Invalid username or password']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection available']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data']);
}
