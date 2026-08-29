import 'package:equatable/equatable.dart';

enum FleetNodeStatus {
  online,
  offline,
  syncing;

  static FleetNodeStatus fromString(String? val) {
    if (val == null) return FleetNodeStatus.offline;
    final lower = val.toLowerCase();
    for (final s in FleetNodeStatus.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return FleetNodeStatus.offline;
  }
}

class FleetNode extends Equatable {
  final String id;
  final String branchName;
  final String ipAddress;
  final String role;
  final FleetNodeStatus status;
  final DateTime lastHeartbeat;
  final int latencyMs;

  const FleetNode({
    required this.id,
    required this.branchName,
    required this.ipAddress,
    required this.role,
    required this.status,
    required this.lastHeartbeat,
    required this.latencyMs,
  });

  bool get isOnline => status == FleetNodeStatus.online;
  bool get isOffline => status == FleetNodeStatus.offline;
  bool get isSyncing => status == FleetNodeStatus.syncing;

  FleetNode copyWith({
    String? id,
    String? branchName,
    String? ipAddress,
    String? role,
    FleetNodeStatus? status,
    DateTime? lastHeartbeat,
    int? latencyMs,
  }) {
    return FleetNode(
      id: id ?? this.id,
      branchName: branchName ?? this.branchName,
      ipAddress: ipAddress ?? this.ipAddress,
      role: role ?? this.role,
      status: status ?? this.status,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }

  factory FleetNode.fromJson(Map<String, dynamic> json) {
    return FleetNode(
      id: json['id']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? 'Main Branch',
      ipAddress: json['ipAddress']?.toString() ?? '127.0.0.1',
      role: json['role']?.toString() ?? 'station',
      status: FleetNodeStatus.fromString(json['status']?.toString()),
      lastHeartbeat: json['lastHeartbeat'] != null
          ? DateTime.parse(json['lastHeartbeat'].toString())
          : DateTime.now(),
      latencyMs: int.tryParse(json['latencyMs']?.toString() ?? '12') ?? 12,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchName': branchName,
      'ipAddress': ipAddress,
      'role': role,
      'status': status.name,
      'lastHeartbeat': lastHeartbeat.toIso8601String(),
      'latencyMs': latencyMs,
    };
  }

  @override
  List<Object?> get props => [
        id,
        branchName,
        ipAddress,
        role,
        status,
        lastHeartbeat,
        latencyMs,
      ];
}
