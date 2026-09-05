import 'package:equatable/equatable.dart';

enum ProfitPoolMode {
  netProfit, // Pool = Gross Sales - Returns - Expenses - Settled Payroll
  grossRevenue, // Pool = Gross Sales
}

class OwnerShareConfig extends Equatable {
  final String ownerId;
  final String ownerName;
  final double sharePercentage; // 0.0 to 100.0

  const OwnerShareConfig({
    required this.ownerId,
    required this.ownerName,
    required this.sharePercentage,
  });

  @override
  List<Object?> get props => [ownerId, ownerName, sharePercentage];
}

class StaffPayrollEntry extends Equatable {
  final String staffId;
  final String staffName;
  final double baseSalary;
  final double unsettledAdvances;
  final double commissions;
  final double bonuses;
  final bool isSettled;

  const StaffPayrollEntry({
    required this.staffId,
    required this.staffName,
    required this.baseSalary,
    this.unsettledAdvances = 0.0,
    this.commissions = 0.0,
    this.bonuses = 0.0,
    this.isSettled = false,
  });

  double get netPayable => (baseSalary + commissions + bonuses - unsettledAdvances).clamp(0.0, double.infinity);

  StaffPayrollEntry copyWithSettled() {
    return StaffPayrollEntry(
      staffId: staffId,
      staffName: staffName,
      baseSalary: baseSalary,
      unsettledAdvances: 0.0,
      commissions: commissions,
      bonuses: bonuses,
      isSettled: true,
    );
  }

  @override
  List<Object?> get props => [staffId, staffName, baseSalary, unsettledAdvances, commissions, bonuses, isSettled];
}

class ProfitSplitCalculationResult extends Equatable {
  final double distributablePool;
  final Map<String, double> ownerPayouts;
  final double totalSettledPayroll;
  final double netOperatingBalance;

  const ProfitSplitCalculationResult({
    required this.distributablePool,
    required this.ownerPayouts,
    required this.totalSettledPayroll,
    required this.netOperatingBalance,
  });

  @override
  List<Object?> get props => [distributablePool, ownerPayouts, totalSettledPayroll, netOperatingBalance];
}

class ManagerProfitSplitEngine {
  ManagerProfitSplitEngine._();

  static ProfitSplitCalculationResult calculateProfitSplit({
    required double grossSales,
    required double returns,
    required double expenses,
    required List<StaffPayrollEntry> payrollEntries,
    required List<OwnerShareConfig> owners,
    ProfitPoolMode poolMode = ProfitPoolMode.netProfit,
  }) {
    // 1. Calculate settled payroll total
    final totalPayroll = payrollEntries.fold<double>(
      0.0,
      (sum, p) => sum + p.netPayable,
    );

    // 2. Distributable Pool calculation
    final double pool;
    if (poolMode == ProfitPoolMode.grossRevenue) {
      pool = grossSales.clamp(0.0, double.infinity);
    } else {
      // Net Profit Mode: Gross - Returns - Expenses - Payroll
      pool = (grossSales - returns - expenses - totalPayroll).clamp(0.0, double.infinity);
    }

    // 3. Validate and calculate owner percentage splits
    final payouts = <String, double>{};
    for (final owner in owners) {
      final payout = pool * (owner.sharePercentage / 100.0);
      payouts[owner.ownerId] = payout;
    }

    final netBalance = (grossSales - returns - expenses - totalPayroll);

    return ProfitSplitCalculationResult(
      distributablePool: pool,
      ownerPayouts: payouts,
      totalSettledPayroll: totalPayroll,
      netOperatingBalance: netBalance,
    );
  }
}
