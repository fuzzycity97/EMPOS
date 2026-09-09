import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _syncUserRoleToLan(UserRole role) {
    try {
      if (di.sl.isRegistered<LanSyncRepository>()) {
        final lanRepo = di.sl<LanSyncRepository>();
        // Only dynamically change role if this machine is a client station (not the host god hub)
        if (!lanRepo.isHost) {
          final id = role == UserRole.doctor
              ? 'doctor'
              : role == UserRole.receptionist
                  ? 'reception'
                  : role == UserRole.cashier
                      ? 'cashier'
                      : 'station-${role.name}';
          final stationRole = role == UserRole.doctor
              ? 'Doctor Station'
              : role == UserRole.receptionist
                  ? 'Reception Desk'
                  : role == UserRole.cashier
                      ? 'POS Cashier'
                      : role == UserRole.admin
                          ? 'Admin Station'
                          : 'Client Station';
          final appName = role == UserRole.doctor
              ? 'EMPOS Clinical / Dental Suite'
              : role == UserRole.receptionist
                  ? 'EMPOS Front-Desk Reception Suite'
                  : role == UserRole.cashier
                      ? 'EMPOS Retail / POS Checkout'
                      : 'EMPOS Client Workstation';
          lanRepo.updateStationIdentity(id: id, role: stationRole, appName: appName);
        }
      }
    } catch (_) {}
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await authRepository.seedDefaultUsers();
    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null && user.isActive) {
          _syncUserRoleToLan(user.role);
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.loginWithPin(event.pin);

    result.fold(
      (failure) => emit(AuthUnauthenticated(errorMessage: failure.message)),
      (user) {
        if (user != null && user.isActive) {
          _syncUserRoleToLan(user.role);
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated(errorMessage: 'User account is inactive.'));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
