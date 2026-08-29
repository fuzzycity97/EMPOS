import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class RoleGuardWidget extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuardWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final bloc = BlocProvider.of<AuthBloc>(context, listen: false);
      return BlocBuilder<AuthBloc, AuthState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is AuthAuthenticated && allowedRoles.contains(state.user.role)) {
            return child;
          }
          return fallback ?? const SizedBox.shrink();
        },
      );
    } catch (_) {
      return fallback ?? const SizedBox.shrink();
    }
  }
}
