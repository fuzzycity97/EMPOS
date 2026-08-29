import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:empos/features/auth/domain/entities/app_user.dart';
import 'package:empos/features/auth/domain/entities/user_role.dart';
import 'package:empos/features/auth/domain/repositories/auth_repository.dart';
import 'package:empos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:empos/features/auth/presentation/bloc/auth_event.dart';
import 'package:empos/features/auth/presentation/bloc/auth_state.dart';
import 'package:empos/features/auth/presentation/widgets/pin_lock_screen.dart';
import 'package:empos/features/auth/presentation/widgets/role_guard_widget.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('Auth Data Layer Tests', () {
    late Directory tempDir;
    late AuthLocalDataSource localDataSource;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('empos_auth_test_');
      Hive.init(tempDir.path);
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    setUp(() async {
      await Hive.openBox<dynamic>(AuthLocalDataSourceImpl.authBoxName);
      localDataSource = AuthLocalDataSourceImpl();
    });

    tearDown(() async {
      final box = await Hive.openBox<dynamic>(AuthLocalDataSourceImpl.authBoxName);
      await box.clear();
    });

    test('Seeds default users with correct roles and PIN hashes', () async {
      await localDataSource.seedDefaultUsers(force: true);
      final users = await localDataSource.getAllUsers();

      expect(users.length, 6);
      expect(users.any((u) => u.role == UserRole.admin && u.pinCodeHash == '0000'), isTrue);
      expect(users.any((u) => u.role == UserRole.doctor && u.pinCodeHash == '1111'), isTrue);
      expect(users.any((u) => u.role == UserRole.cashier && u.pinCodeHash == '2222'), isTrue);
      expect(users.any((u) => u.role == UserRole.receptionist && u.pinCodeHash == '3333'), isTrue);
      expect(users.any((u) => u.role == UserRole.manager && u.pinCodeHash == '4444'), isTrue);
      expect(users.any((u) => u.role == UserRole.technician && u.pinCodeHash == '5555'), isTrue);
    });

    test('loginWithPin returns user on valid PIN and saves session', () async {
      final admin = await localDataSource.loginWithPin('0000');
      expect(admin, isNotNull);
      expect(admin?.role, UserRole.admin);

      final current = await localDataSource.getCurrentUser();
      expect(current?.id, admin?.id);

      await localDataSource.logout();
      expect(await localDataSource.getCurrentUser(), isNull);
    });

    test('loginWithPin returns null on invalid PIN', () async {
      final invalid = await localDataSource.loginWithPin('9999');
      expect(invalid, isNull);
    });
  });

  group('AuthBloc Unit Tests', () {
    late MockAuthRepository mockAuthRepository;

    const sampleAdmin = AppUser(
      id: 'usr_admin',
      name: 'Admin Director',
      role: UserRole.admin,
      pinCodeHash: '0000',
      isActive: true,
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      when(() => mockAuthRepository.seedDefaultUsers()).thenAnswer((_) async => const Right(null));
    });

    test('Initial state is AuthInitial', () {
      final bloc = AuthBloc(authRepository: mockAuthRepository);
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });

    test('AppStarted emits AuthAuthenticated when active session exists', () async {
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => const Right(sampleAdmin));

      final bloc = AuthBloc(authRepository: mockAuthRepository);
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const AuthLoading(),
        const AuthAuthenticated(sampleAdmin),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test('LoginRequested with valid PIN emits AuthAuthenticated', () async {
      when(() => mockAuthRepository.loginWithPin('0000')).thenAnswer((_) async => const Right(sampleAdmin));

      final bloc = AuthBloc(authRepository: mockAuthRepository);
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginRequested('0000'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const AuthLoading(),
        const AuthAuthenticated(sampleAdmin),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test('LogoutRequested emits AuthUnauthenticated', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => const Right(null));

      final bloc = AuthBloc(authRepository: mockAuthRepository);
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LogoutRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const AuthUnauthenticated(),
      ]);

      await sub.cancel();
      await bloc.close();
    });
  });

  group('RoleGuardWidget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('Renders child when user role is in allowedRoles', (tester) async {
      const doctorUser = AppUser(
        id: 'usr_doc',
        name: 'Dr. Sarah',
        role: UserRole.doctor,
        pinCodeHash: '1111',
      );

      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(doctorUser));
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const RoleGuardWidget(
              allowedRoles: [UserRole.admin, UserRole.doctor],
              child: Text('Doctor Clinical Station'),
            ),
          ),
        ),
      );

      expect(find.text('Doctor Clinical Station'), findsOneWidget);
    });

    testWidgets('Hides child when user role is not in allowedRoles', (tester) async {
      const cashierUser = AppUser(
        id: 'usr_cash',
        name: 'Ahmed',
        role: UserRole.cashier,
        pinCodeHash: '2222',
      );

      when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(cashierUser));
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const RoleGuardWidget(
              allowedRoles: [UserRole.admin, UserRole.doctor],
              child: Text('Doctor Clinical Station'),
            ),
          ),
        ),
      );

      expect(find.text('Doctor Clinical Station'), findsNothing);
    });
  });

  group('PinLockScreen Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('Renders PIN Lock Screen elements and demo chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: PinLockScreen(),
          ),
        ),
      );

      expect(find.text('EMPOS™ Station Security'), findsOneWidget);
      expect(find.text('Enter your 4-digit security PIN to unlock station'), findsOneWidget);
      expect(find.text('Admin (0000)'), findsOneWidget);
      expect(find.text('Doctor (1111)'), findsOneWidget);
      expect(find.text('Cashier (2222)'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Tapping demo chip dispatches LoginRequested with corresponding PIN', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: PinLockScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Admin (0000)'));
      await tester.tap(find.text('Admin (0000)'));
      await tester.pump();

      verify(() => mockAuthBloc.add(const LoginRequested('0000'))).called(1);
    });

    testWidgets('Entering 4 digits on keypad dispatches LoginRequested', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: PinLockScreen(),
          ),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      verify(() => mockAuthBloc.add(const LoginRequested('1111'))).called(1);
    });
  });
}
