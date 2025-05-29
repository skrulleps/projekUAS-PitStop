import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final UserBloc _userBloc;

  LoginBloc({required AuthRepository authRepository, required UserBloc userBloc})
      : _authRepository = authRepository,
        _userBloc = userBloc,
        super(LoginState.initial()) {
    on<LoginEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<LoginSubmitted>((event, emit) async {
      final email = (state.email ?? '').trim();
      final password = (state.password ?? '').trim();
      print('Login attempt with email: $email, password: $password');
      if (email.isEmpty || password.isEmpty) {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
        return;
      }
      emit(state.copyWith(
          isSubmitting: true, isFailure: false, isSuccess: false));
      try {
        final res = await _authRepository.getUserByEmailAndPassword(email, password);
        print('Login response: $res');

        if (res != null) {
          final role = res['role'] as String?;
          final userId = res['id']?.toString();
          if (userId != null) {
            _userBloc.add(UserLoggedIn(userId));
          }
          emit(state.copyWith(
              isSubmitting: false, isSuccess: true, userRole: role));
        } else {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
        }
      } catch (error) {
        print('Login error: $error');
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    });
  }
}
