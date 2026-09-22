import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/login.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;

  AuthCubit({required this.loginUseCase}) : super(const AuthInitial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    // Guard against duplicate submission during loading
    if (state is AuthLoading) return;

    emit(const AuthLoading());

    try {
      final user = await loginUseCase(username: username, password: password);
      emit(AuthSuccess(user));
    } on Failure catch (failure) {
      emit(AuthFailure(failure.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
