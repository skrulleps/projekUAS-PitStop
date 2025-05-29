import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../auth_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegisterState.initial()) {
    on<RegisterEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<RegisterPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<RegisterSubmitted>((event, emit) async {
      emit(state.copyWith(
          isSubmitting: true,
          isFailure: false,
          isSuccess: false,
          errorMessage: ''));

      final email = (event.email ?? '').trim();
      final password = (event.password ?? '').trim();

      if (email.isEmpty || password.isEmpty) {
        emit(state.copyWith(
          isSubmitting: false,
          isFailure: true,
          errorMessage: 'Email dan password tidak boleh kosong',
        ));
        return;
      }

      try {
        await _authRepository.signUp(email, password, event.username ?? '');
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } catch (error) {
        print('Register error: $error');
        emit(state.copyWith(
            isSubmitting: false,
            isFailure: true,
            errorMessage: error.toString()));
      }
    });
  }
}
