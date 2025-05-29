import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoadSuccess extends UserState {
  final String userId;
  final String? username;

  const UserLoadSuccess({required this.userId, this.username});

  @override
  List<Object?> get props => [userId, username];
}

class UserLoadFailure extends UserState {}
