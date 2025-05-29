import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import 'package:pitstop/auth/auth_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthRepository authRepository;

  UserBloc({required this.authRepository}) : super(UserInitial()) {
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserLoggedOut>(_onUserLoggedOut);
  }

  Future<void> _onUserLoggedIn(UserLoggedIn event, Emitter<UserState> emit) async {
    try {
      final username = await authRepository.getUsernameById(event.userId);
      emit(UserLoadSuccess(userId: event.userId, username: username));
    } catch (_) {
      emit(UserLoadFailure());
    }
  }

  Future<void> _onUserLoggedOut(UserLoggedOut event, Emitter<UserState> emit) async {
    // Hanya emit state tanpa memanggil signOut lagi untuk mencegah loop
    emit(UserInitial());
  }
}
