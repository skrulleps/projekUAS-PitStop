import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String? email;
  final String? password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? userRole;

  LoginState({
    this.email,
    this.password,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.userRole,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? userRole,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [email, password, isSubmitting, isSuccess, isFailure, userRole];

  factory LoginState.initial() {
    return LoginState();
  }
}
