enum SubscriptionAuditAction {
  tierChanged,
  overrideSet,
  overrideCleared,
  overridesReset,
}

class SubscriptionAuditRecord {
  final String id;
  final String accountId;
  final String adminId;
  final SubscriptionAuditAction action;
  final String targetKey;
  final String oldValue;
  final String newValue;
  final DateTime timestamp;

  SubscriptionAuditRecord({
    required this.id,
    required this.accountId,
    required this.adminId,
    required this.action,
    required this.targetKey,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'adminId': adminId,
        'action': action.name,
        'targetKey': targetKey,
        'oldValue': oldValue,
        'newValue': newValue,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SubscriptionAuditRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionAuditRecord(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      adminId: json['adminId'] as String,
      action: SubscriptionAuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => SubscriptionAuditAction.overrideSet,
      ),
      targetKey: json['targetKey'] as String,
      oldValue: json['oldValue'] as String,
      newValue: json['newValue'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get actionLabel {
    switch (action) {
      case SubscriptionAuditAction.tierChanged:
        return 'Plan Tier Changed';
      case SubscriptionAuditAction.overrideSet:
        return 'Capability Override Set';
      case SubscriptionAuditAction.overrideCleared:
        return 'Override Cleared (Reverted to Preset)';
      case SubscriptionAuditAction.overridesReset:
        return 'All Overrides Reset to Tier Preset';
    }
  }
}

/// Append-only audit log for subscription capability and tier mutations.
///
/// Designed per OmniSys audit log security specifications: entries are strictly
/// append-only and cannot be mutated or deleted.
class SubscriptionAuditLog {
  static final SubscriptionAuditLog _instance = SubscriptionAuditLog._internal();
  factory SubscriptionAuditLog() => _instance;
  static SubscriptionAuditLog get instance => _instance;

  SubscriptionAuditLog._internal();

  final List<SubscriptionAuditRecord> _records = [];

  /// Appends an immutable audit record to the log.
  void append(SubscriptionAuditRecord record) {
    _records.add(record);
  }

  /// Appends a new audit record constructed from action details.
  void record({
    required String accountId,
    required String adminId,
    required SubscriptionAuditAction action,
    required String targetKey,
    required String oldValue,
    required String newValue,
  }) {
    final record = SubscriptionAuditRecord(
      id: 'aud_',
      accountId: accountId,
      adminId: adminId,
      action: action,
      targetKey: targetKey,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    );
    append(record);
  }

  /// Returns an unmodifiable list of all audit records (reverse-chronological).
  List<SubscriptionAuditRecord> get records =>
      List.unmodifiable(_records.reversed.toList());

  /// Returns unmodifiable audit records filtered by account ID.
  List<SubscriptionAuditRecord> getRecordsForAccount(String accountId) {
    return List.unmodifiable(
      _records.where((r) => r.accountId == accountId).toList().reversed.toList(),
    );
  }

  /// Returns the total count of recorded audit entries.
  int get count => _records.length;

  /// Clear is only permitted for testing fixtures.
  void clearForTesting() {
    _records.clear();
  }
}
