import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/config/domain/usecases/get_feature_toggle_usecase.dart';
import 'package:empos/core/config/domain/usecases/load_store_blueprint_usecase.dart';
import 'package:empos/core/config/domain/usecases/save_store_blueprint_usecase.dart';
import 'package:empos/core/config/presentation/bloc/config_bloc.dart';
import 'package:empos/core/config/presentation/bloc/config_event.dart';
import 'package:empos/core/config/presentation/bloc/config_state.dart';

class MockLoadStoreBlueprintUseCase extends Mock implements LoadStoreBlueprintUseCase {}
class MockSaveStoreBlueprintUseCase extends Mock implements SaveStoreBlueprintUseCase {}
class MockGetFeatureToggleUseCase extends Mock implements GetFeatureToggleUseCase {}

void main() {
  late MockLoadStoreBlueprintUseCase mockLoadBlueprint;
  late MockSaveStoreBlueprintUseCase mockSaveBlueprint;
  late MockGetFeatureToggleUseCase mockGetToggle;
  late ConfigBloc configBloc;

  final tBlueprint = StoreBlueprint(
    storeName: 'Downtown Pharmacy',
    industryType: IndustryType.pharmacy,
    themeColorHex: '#10B981',
    toggles: const {
      'sw.box_and_strip_selling': true,
      'hw.barcode_scanner': true,
    },
  );

  setUpAll(() {
    registerFallbackValue(
      const StoreBlueprint(storeName: 'fallback'),
    );
  });

  setUp(() {
    mockLoadBlueprint = MockLoadStoreBlueprintUseCase();
    mockSaveBlueprint = MockSaveStoreBlueprintUseCase();
    mockGetToggle = MockGetFeatureToggleUseCase();

    configBloc = ConfigBloc(
      loadStoreBlueprintUseCase: mockLoadBlueprint,
      saveStoreBlueprintUseCase: mockSaveBlueprint,
      getFeatureToggleUseCase: mockGetToggle,
    );
  });

  tearDown(() {
    configBloc.close();
  });

  group('ConfigBloc Tests', () {
    test('initial state is ConfigInitial', () {
      expect(configBloc.state, equals(const ConfigInitial()));
    });

    test('emits [ConfigLoading, ConfigLoaded] when LoadConfigEvent succeeds', () async {
      when(() => mockLoadBlueprint()).thenAnswer((_) async => Right(tBlueprint));

      final expectedStates = [
        const ConfigLoading(),
        isA<ConfigLoaded>().having((s) => s.blueprint.storeName, 'storeName', 'Downtown Pharmacy'),
      ];

      expectLater(configBloc.stream, emitsInOrder(expectedStates));

      configBloc.add(const LoadConfigEvent());
    });

    test('updates feature toggle and emits updated ConfigLoaded state on SetToggleEvent', () async {
      when(() => mockLoadBlueprint()).thenAnswer((_) async => Right(tBlueprint));
      when(() => mockSaveBlueprint(any())).thenAnswer((_) async => const Right(null));

      configBloc.add(const LoadConfigEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      configBloc.add(const SetToggleEvent(toggleKey: 'sw.insurance_claims', isEnabled: true));

      expectLater(
        configBloc.stream,
        emits(
          isA<ConfigLoaded>().having(
            (s) => s.blueprint.isEnabled('sw.insurance_claims'),
            'insurance claims toggle',
            isTrue,
          ),
        ),
      );
    });
  });
}
