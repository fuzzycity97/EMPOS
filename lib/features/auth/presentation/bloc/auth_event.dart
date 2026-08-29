import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String pin;

  const LoginRequested(this.pin);

  @override
  List<Object?> get props => [pin];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
