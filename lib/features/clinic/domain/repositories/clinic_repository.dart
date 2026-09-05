import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../entities/patient_profile.dart';

import '../entities/medical_risk_factor.dart';

abstract class ClinicRepository {
  Future<Either<Failure, List<PatientProfile>>> getPatients();
  Future<Either<Failure, PatientProfile>> savePatient(PatientProfile patient);
  Future<Either<Failure, List<PatientProfile>>> searchPatients(String query);

  Future<Either<Failure, List<ClinicVisit>>> getQueue({String? doctorName});
  Future<Either<Failure, ClinicVisit>> checkInPatient(ClinicVisit visit);
  Future<Either<Failure, ClinicVisit>> updateVisitStatus(String visitId, ClinicVisitStatus status);
  Future<Either<Failure, ClinicVisit>> completeVisit(ClinicVisit visit);
  Future<Either<Failure, ClinicVisit>> saveVisit(ClinicVisit visit);

  /// Rolling mean consultation wait time (in minutes) based on last 5 completed visits
  Future<Either<Failure, int>> getRollingMeanWaitMinutes(String doctorName);

  // Medical Risk Factors
  Future<Either<Failure, List<MedicalRiskFactor>>> getMedicalRiskFactors();
  Future<Either<Failure, void>> saveMedicalRiskFactors(List<MedicalRiskFactor> factors);
}
