import 'package:equatable/equatable.dart';

class ConnectedNode extends Equatable {
  final String id;
  final String role;
  final String ipAddress;
  final DateTime connectedAt;
  final String appName;

  ConnectedNode({
    required this.id,
    required this.role,
    required this.ipAddress,
    DateTime? connectedAt,
    String? appName,
  })  : connectedAt = connectedAt ?? DateTime.now(),
        appName = appName ?? _inferAppName(role);

  static String _inferAppName(String role) {
    final r = role.toLowerCase();
    if (r.contains('doctor') || r.contains('clinic')) return 'EMPOS Clinical / Dental Suite';
    if (r.contains('pos') || r.contains('cashier')) return 'EMPOS Retail POS Register';
    if (r.contains('recept')) return 'EMPOS Reception & Queue Desk';
    if (r.contains('host') || r.contains('server') || r.contains('hub')) return 'EMPOS Central Store Server';
    if (r.contains('tech')) return 'EMPOS Technician Provisioning Tool';
    return 'EMPOS Universal Station';
  }

  factory ConnectedNode.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? 'station';
    return ConnectedNode(
      id: json['id']?.toString() ?? '',
      role: role,
      ipAddress: json['ipAddress']?.toString() ?? json['ip']?.toString() ?? '127.0.0.1',
      connectedAt: DateTime.tryParse(json['connectedAt']?.toString() ?? '') ?? DateTime.now(),
      appName: json['appName']?.toString() ?? _inferAppName(role),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'ipAddress': ipAddress,
      'connectedAt': connectedAt.toIso8601String(),
      'appName': appName,
    };
  }

  ConnectedNode copyWith({
    String? id,
    String? role,
    String? ipAddress,
    DateTime? connectedAt,
    String? appName,
  }) {
    return ConnectedNode(
      id: id ?? this.id,
      role: role ?? this.role,
      ipAddress: ipAddress ?? this.ipAddress,
      connectedAt: connectedAt ?? this.connectedAt,
      appName: appName ?? this.appName,
    );
  }

  @override
  List<Object?> get props => [id, role, ipAddress, connectedAt, appName];
}
