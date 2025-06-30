import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test1/feature/auth/logic/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  AuthCubit(this._authRepo) : super(AuthInitial());

  void test() {
    print("---- cubit created sucessfully");
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(AuthError("Please fill all fields"));
      return;
    }
    emit(AuthLoading());
    try {
      await _authRepo.signupWithEmail(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepo.loginWithEmail(email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _authRepo.signupWithGoogle();
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    try {
      await _authRepo.signInWithFacebook();
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
