import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoggedIn extends UserEvent {
  final String userId;

  const UserLoggedIn(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserLoggedOut extends UserEvent {}
