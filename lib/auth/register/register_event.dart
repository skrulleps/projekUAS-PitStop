abstract class RegisterEvent {}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  RegisterEmailChanged(this.email);
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  RegisterPasswordChanged(this.password);
}

class RegisterSubmitted extends RegisterEvent {
  final String? username;
  final String? email;
  final String? password;

  RegisterSubmitted({this.username, this.email, this.password});
}
