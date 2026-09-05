import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/medical_risk_factor.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_local_data_source.dart';
import '../models/clinic_visit_model.dart';
import '../models/medical_risk_factor_model.dart';
import '../models/patient_profile_model.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicLocalDataSource localDataSource;

  ClinicRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PatientProfile>>> getPatients() async {
    try {
      final models = await localDataSource.getPatients();
      return Right(models);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error retrieving patients: $e'));
    }
  }

  @override
  Future<Either<Failure, PatientProfile>> savePatient(PatientProfile patient) async {
    try {
      final model = PatientProfileModel.fromEntity(patient);
      await localDataSource.savePatient(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving patient: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PatientProfile>>> searchPatients(String query) async {
    try {
      final models = await localDataSource.getPatients();
      if (query.trim().isEmpty) return Right(models);

      final lower = query.trim().toLowerCase();
      final filtered = models.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            p.phone.contains(lower) ||
            (p.insuranceProvider?.toLowerCase().contains(lower) ?? false) ||
            (p.policyNumber?.toLowerCase().contains(lower) ?? false);
      }).toList();

      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error searching patients: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ClinicVisit>>> getQueue({String? doctorName}) async {
    try {
      final allVisits = await localDataSource.getVisits();
      var queue = allVisits.where((v) {
        final isActive = v.status == ClinicVisitStatus.waiting ||
            v.status == ClinicVisitStatus.inExamination ||
            v.status == ClinicVisitStatus.completed;
        if (!isActive) return false;
        if (doctorName != null && doctorName.trim().isNotEmpty) {
          return v.doctorName.toLowerCase() == doctorName.trim().toLowerCase();
        }
        return true;
      }).toList();

      queue.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
      return Right(queue);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error fetching clinic queue: $e'));
    }
  }

  @override
  Future<Either<Failure, ClinicVisit>> checkInPatient(ClinicVisit visit) async {
    try {
      final allVisits = await localDataSource.getVisits();
      final activeForDoctor = allVisits.where((v) =>
          v.doctorName.toLowerCase() == visit.doctorName.toLowerCase() &&
          (v.status == ClinicVisitStatus.waiting || v.status == ClinicVisitStatus.inExamination));

      final queueNum = activeForDoctor.length + 1;
      final assignedVisit = visit.copyWith(queueNumber: queueNum, status: ClinicVisitStatus.waiting);

      final model = ClinicVisitModel.fromEntity(assignedVisit);
      await localDataSource.saveVisit(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error checking in patient: $e'));
    }
  }

  @override
  Future<Either<Failure, ClinicVisit>> updateVisitStatus(String visitId, ClinicVisitStatus status) async {
    try {
      final existing = await localDataSource.getVisitById(visitId);
      if (existing == null) {
        return Left(CacheFailure(message: 'Visit $visitId not found'));
      }

      DateTime? consultStart = existing.consultationStartTime;
      DateTime? completion = existing.completionTime;

      if (status == ClinicVisitStatus.inExamination && consultStart == null) {
        consultStart = DateTime.now();
      } else if (status == ClinicVisitStatus.completed && completion == null) {
        completion = DateTime.now();
      }

      final updated = existing.copyWith(
        status: status,
        consultationStartTime: consultStart,
        completionTime: completion,
      );

      final model = ClinicVisitModel.fromEntity(updated);
      await localDataSource.saveVisit(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error updating visit status: $e'));
    }
  }

  @override
  Future<Either<Failure, ClinicVisit>> completeVisit(ClinicVisit visit) async {
    try {
      double totalFee = 0.0;
      double insurancePaid = 0.0;

      for (final proc in visit.appliedProcedures) {
        totalFee += proc.standardFee;
        insurancePaid += proc.insuranceShare;
      }

      totalFee = double.parse(totalFee.toStringAsFixed(2));
      insurancePaid = double.parse(insurancePaid.toStringAsFixed(2));
      final patientCopay = double.parse(
        (totalFee - insurancePaid).clamp(0.0, double.infinity).toStringAsFixed(2),
      );

      final completedVisit = visit.copyWith(
        status: ClinicVisitStatus.completed,
        completionTime: visit.completionTime ?? DateTime.now(),
        totalFee: totalFee,
        insurancePaid: insurancePaid,
        patientCopay: patientCopay,
      );

      final model = ClinicVisitModel.fromEntity(completedVisit);
      await localDataSource.saveVisit(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error completing visit: $e'));
    }
  }

  @override
  Future<Either<Failure, ClinicVisit>> saveVisit(ClinicVisit visit) async {
    try {
      final model = ClinicVisitModel.fromEntity(visit);
      await localDataSource.saveVisit(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving visit: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRollingMeanWaitMinutes(String doctorName) async {
    try {
      final allVisits = await localDataSource.getVisits();

      // 1. Get queue ahead of the new patient for this doctor
      final waitingQueue = allVisits.where((v) =>
          v.doctorName.toLowerCase() == doctorName.toLowerCase() &&
          v.status == ClinicVisitStatus.waiting).toList();

      final queuePosition = waitingQueue.length;
      if (queuePosition == 0) return const Right(0);

      // 2. Find up to last 5 completed visits with valid durations
      final completedForDoctor = allVisits.where((v) =>
          v.doctorName.toLowerCase() == doctorName.toLowerCase() &&
          v.status == ClinicVisitStatus.completed &&
          v.consultationStartTime != null &&
          v.completionTime != null).toList();

      completedForDoctor.sort((a, b) => b.completionTime!.compareTo(a.completionTime!));
      final recentCompleted = completedForDoctor.take(5).toList();

      double avgMinutesPerConsultation = 15.0; // Default baseline if no history exists

      if (recentCompleted.isNotEmpty) {
        final totalMinutes = recentCompleted.fold<int>(
          0,
          (sum, v) => sum + v.consultationDurationMinutes,
        );
        avgMinutesPerConsultation = totalMinutes / recentCompleted.length;
        if (avgMinutesPerConsultation < 5.0) {
          avgMinutesPerConsultation = 5.0; // Realistic minimum floor
        }
      }

      final estimatedWaitMinutes = (queuePosition * avgMinutesPerConsultation).round();
      return Right(estimatedWaitMinutes);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error calculating wait time: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MedicalRiskFactor>>> getMedicalRiskFactors() async {
    try {
      final factors = await localDataSource.getMedicalRiskFactors();
      return Right(factors);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error getting medical risk factors: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveMedicalRiskFactors(List<MedicalRiskFactor> factors) async {
    try {
      final models = factors
          .map((f) => f is MedicalRiskFactorModel ? f : MedicalRiskFactorModel.fromEntity(f))
          .toList();
      await localDataSource.saveMedicalRiskFactors(models);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving medical risk factors: $e'));
    }
  }
}
