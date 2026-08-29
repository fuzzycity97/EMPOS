enum UserRole {
  admin,
  manager,
  cashier,
  doctor,
  receptionist,
  technician;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Store Manager';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.doctor:
        return 'Doctor / Specialist';
      case UserRole.receptionist:
        return 'Reception Desk';
      case UserRole.technician:
        return 'Technician / Trades';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.cashier,
    );
  }
}
