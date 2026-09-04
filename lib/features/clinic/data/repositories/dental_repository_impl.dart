import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dental_treatment_plan.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import '../../domain/repositories/dental_repository.dart';
import '../datasources/clinic_local_data_source.dart';
import '../models/dental_treatment_plan_model.dart';
import '../models/tooth_chart_entry_model.dart';

class DentalRepositoryImpl implements DentalRepository {
  final ClinicLocalDataSource localDataSource;

  DentalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ToothChartEntry>>> getPatientToothChart(
    String patientId, {
    DateTime? dateOfBirth,
  }) async {
    try {
      // Check patient profile if DOB not supplied directly
      DateTime? effectiveDob = dateOfBirth;
      if (effectiveDob == null) {
        final patient = await localDataSource.getPatientById(patientId);
        if (patient?.dateOfBirth != null) {
          effectiveDob = DateTime.tryParse(patient!.dateOfBirth!);
        }
      }

      // Pediatric (< 12 years old) gets 20 Deciduous Teeth (A through T)
      bool isPediatric = false;
      if (effectiveDob != null) {
        final ageInDays = DateTime.now().difference(effectiveDob).inDays;
        isPediatric = ageInDays < (12 * 365.25);
      }

      // 1. Generate baseline chart (Pediatric vs Adult)
      List<ToothChartEntry> baseTeeth;
      if (isPediatric) {
        baseTeeth = ToothChartEntry.primaryToothCodes.asMap().entries.map((entry) {
          return ToothChartEntry(
            toothNumber: entry.key + 1,
            toothCode: entry.value,
            isDeciduous: true,
            state: ToothState.healthy,
          );
        }).toList();
      } else {
        baseTeeth = List.generate(
          32,
          (index) => ToothChartEntry(
            toothNumber: index + 1,
            toothCode: (index + 1).toString(),
            isDeciduous: false,
            state: ToothState.healthy,
          ),
        );
      }

      final Map<String, ToothChartEntry> cumulativeMap = {
        for (final t in baseTeeth) t.effectiveToothCode.toUpperCase(): t,
      };

      // 2. Cumulative merge: Replay all historical visits for this patient chronologically
      try {
        final allVisits = await localDataSource.getVisits();
        final patientVisits = allVisits.where((v) => v.patientId == patientId).toList();
        patientVisits.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));

        for (final visit in patientVisits) {
          for (final entry in visit.toothChart) {
            final code = entry.effectiveToothCode.toUpperCase();
            final existing = cumulativeMap[code];
            if (existing != null) {
              cumulativeMap[code] = _mergeToothEntries(existing, entry);
            } else {
              cumulativeMap[code] = entry;
            }
          }
        }
      } catch (_) {}

      // 3. Cumulative merge: Layer in explicitly saved tooth chart entries
      try {
        final savedEntries = await localDataSource.getToothChart(patientId);
        for (final entry in savedEntries) {
          final code = entry.effectiveToothCode.toUpperCase();
          final existing = cumulativeMap[code];
          if (existing != null) {
            cumulativeMap[code] = _mergeToothEntries(existing, entry);
          } else {
            cumulativeMap[code] = entry;
          }
        }
      } catch (_) {}

      final result = cumulativeMap.values.toList();
      result.sort((a, b) => a.toothNumber.compareTo(b.toothNumber));
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error getting tooth chart: $e'));
    }
  }

  ToothChartEntry _mergeToothEntries(ToothChartEntry oldEntry, ToothChartEntry newEntry) {
    final effectiveState = (newEntry.state != ToothState.healthy)
        ? newEntry.state
        : oldEntry.state;
    final mergedHistory = <ToothHistoryEntry>[...oldEntry.history];
    for (final h in newEntry.history) {
      if (!mergedHistory.any((x) => x.timestamp == h.timestamp && x.state == h.state)) {
        mergedHistory.add(h);
      }
    }
    return oldEntry.copyWith(
      state: effectiveState,
      pocketDepthMm: newEntry.pocketDepthMm > 1 ? newEntry.pocketDepthMm : oldEntry.pocketDepthMm,
      surfaceNotation: newEntry.surfaceNotation.isNotEmpty ? newEntry.surfaceNotation : oldEntry.surfaceNotation,
      notes: (newEntry.notes != null && newEntry.notes!.isNotEmpty) ? newEntry.notes : oldEntry.notes,
      specialCaseType: newEntry.specialCaseType ?? oldEntry.specialCaseType,
      history: mergedHistory,
    );
  }

  @override
  Future<Either<Failure, void>> saveToothChart(
    String patientId,
    List<ToothChartEntry> entries,
  ) async {
    try {
      final models = entries
          .map((e) => e is ToothChartEntryModel ? e : ToothChartEntryModel.fromEntity(e))
          .toList();
      await localDataSource.saveToothChart(patientId, models);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving tooth chart: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DentalTreatmentPlan>>> getTreatmentPlans(String patientId) async {
    try {
      final plans = await localDataSource.getDentalPlans(patientId);
      return Right(plans);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error getting treatment plans: $e'));
    }
  }

  @override
  Future<Either<Failure, DentalTreatmentPlan>> saveTreatmentPlan(DentalTreatmentPlan plan) async {
    try {
      final model = plan is DentalTreatmentPlanModel
          ? plan
          : DentalTreatmentPlanModel.fromEntity(plan);
      await localDataSource.saveDentalPlan(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving treatment plan: $e'));
    }
  }
}